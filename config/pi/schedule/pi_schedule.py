"""Runs scheduled pi tasks in Herdr.

launchd calls `tick` every minute. Each due task opens a tab in the "scheduled" Herdr
workspace and starts an interactive pi on the task's prompt.

A task is TASKS_DIR/<id>.md: `key: value` frontmatter followed by the prompt. The
`schedule` skill documents the format.

Times are naive local datetimes: schedules are wall-clock, and stepping through dates
rather than durations keeps slots correct across DST changes.
"""

import json
import re
import shlex
import subprocess
import sys
from dataclasses import dataclass, field
from datetime import date, datetime, time, timedelta
from pathlib import Path

TASKS_DIR = Path.home() / ".config/pi-schedule/tasks"
STATE_DIR = Path.home() / ".local/state/pi-schedule"
STATE_FILE = STATE_DIR / "state.json"
WORKSPACE = "scheduled"

KEYS = {"schedule", "cwd", "model", "tools", "enabled"}
DAYS = {"mon": 1, "tue": 2, "wed": 3, "thu": 4, "fri": 5, "sat": 6, "sun": 7}
# A run that starts later than this after its slot shows both times in its tab label.
LATE = timedelta(minutes=5)
# pi reports `idle` while it starts up, so `clean` leaves younger runs alone.
STARTUP = timedelta(minutes=2)


class TaskError(Exception):
    """A task file that cannot run as written."""


class HerdrError(Exception):
    """A Herdr command failed."""


@dataclass(frozen=True)
class Schedule:
    text: str = field(compare=False)
    at: time
    days: frozenset[int] = frozenset()  # ISO weekdays of a recurring schedule
    on: date | None = None  # date of a one-off schedule

    @classmethod
    def parse(cls, text: str) -> "Schedule":
        match text.split():
            case ["once", day, at]:
                return cls(text, _time(at), on=_date(day))
            case ["daily", at]:
                return cls(text, _time(at), days=frozenset(range(1, 8)))
            case ["weekdays", at]:
                return cls(text, _time(at), days=frozenset(range(1, 6)))
            case [days, at] if all(day in DAYS for day in days.split(",")):
                return cls(
                    text,
                    _time(at),
                    days=frozenset(DAYS[day] for day in days.split(",")),
                )
        raise TaskError(f"invalid schedule {text!r}")

    def last(self, now: datetime) -> datetime | None:
        """The latest slot at or before `now`."""
        return next((slot for slot in self._slots(now, -1) if slot <= now), None)

    def next(self, now: datetime) -> datetime | None:
        """The first slot after `now`."""
        return next((slot for slot in self._slots(now, 1) if slot > now), None)

    def _slots(self, now: datetime, step: int):
        if self.on:
            yield datetime.combine(self.on, self.at)
            return
        for offset in range(8):
            day = now.date() + timedelta(days=offset * step)
            if day.isoweekday() in self.days:
                yield datetime.combine(day, self.at)


def _time(text: str) -> time:
    if not re.fullmatch(r"\d{2}:\d{2}", text):
        raise TaskError(f"invalid time {text!r}, expected HH:MM")
    try:
        return time.fromisoformat(text)
    except ValueError:
        raise TaskError(f"invalid time {text!r}") from None


def _date(text: str) -> date:
    try:
        return date.fromisoformat(text)
    except ValueError:
        raise TaskError(f"invalid date {text!r}, expected YYYY-MM-DD") from None


@dataclass(frozen=True)
class Task:
    id: str
    schedule: Schedule
    cwd: Path
    prompt: str
    written: datetime
    model: str | None = None
    tools: str | None = None
    enabled: bool = True

    @classmethod
    def load(cls, path: Path) -> "Task":
        lines = path.read_text().split("\n")
        if lines[0] != "---" or "---" not in lines[1:]:
            raise TaskError("missing --- frontmatter")
        end = lines.index("---", 1)

        fields = {}
        for line in filter(str.strip, lines[1:end]):
            key, sep, value = line.partition(":")
            key = key.strip()
            if not sep or key not in KEYS:
                raise TaskError(
                    f"unknown key {key!r}, expected one of {', '.join(sorted(KEYS))}"
                )
            fields[key] = value.strip().strip("\"'")

        if "schedule" not in fields:
            raise TaskError("missing schedule")
        prompt = "\n".join(lines[end + 1 :]).strip()
        if not prompt:
            raise TaskError("empty prompt")
        # Herdr silently opens a missing directory as ~, where the run would act on the wrong files.
        cwd = Path(fields.get("cwd", "~")).expanduser()
        if not cwd.is_dir():
            raise TaskError(f"cwd {cwd} is not a directory")
        enabled = fields.get("enabled", "true")
        if enabled not in ("true", "false"):
            raise TaskError(f"invalid enabled {enabled!r}, expected true or false")

        return cls(
            id=path.stem,
            schedule=Schedule.parse(fields["schedule"]),
            cwd=cwd,
            prompt=prompt + "\n",
            written=datetime.fromtimestamp(path.stat().st_mtime),
            model=fields.get("model") or None,
            tools=fields.get("tools") or None,
            enabled=enabled == "true",
        )

    def due(self, last_run: datetime | None, now: datetime) -> datetime | None:
        """The slot to run now, if any. Missed slots collapse into the latest one."""
        slot = self.schedule.last(now)
        if not self.enabled or slot is None:
            return None
        if last_run is None:
            # A new recurring task counts from when its file was written, so it does not
            # fire for a slot that passed before it existed. A one-off was asked for
            # explicitly, so it fires even if its time had passed.
            last_run = datetime.min if self.schedule.on else self.written
        return slot if slot > last_run else None


def load_state() -> dict:
    return json.loads(STATE_FILE.read_text()) if STATE_FILE.exists() else {}


def save_state(state: dict) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    tmp = STATE_FILE.with_suffix(".tmp")
    tmp.write_text(json.dumps(state, indent=2) + "\n")
    tmp.replace(STATE_FILE)


def last_run(entry: dict) -> datetime | None:
    return datetime.fromtimestamp(entry["last"]) if "last" in entry else None


def herdr(*args: str) -> dict:
    proc = subprocess.run(["herdr", *args], capture_output=True, text=True, check=False)
    if proc.returncode != 0:
        raise HerdrError(
            f"herdr {' '.join(args[:2])}: {proc.stderr.strip() or proc.stdout.strip()}"
        )
    return json.loads(proc.stdout)["result"] if proc.stdout.strip() else {}


def herdr_running() -> bool:
    return (
        subprocess.run(
            ["herdr", "workspace", "list"], capture_output=True, check=False
        ).returncode
        == 0
    )


def scheduled_workspace() -> str | None:
    workspaces = herdr("workspace", "list")["workspaces"]
    return next(
        (w["workspace_id"] for w in workspaces if w["label"] == WORKSPACE), None
    )


def launch(task: Task, slot: datetime, now: datetime) -> str:
    """Starts the task in a new tab and returns the tab's id."""
    prompt_file = STATE_DIR / "runs" / f"{task.id}-{now:%Y%m%d-%H%M}.md"
    prompt_file.parent.mkdir(parents=True, exist_ok=True)
    prompt_file.write_text(task.prompt)

    label = f"{task.id} · {slot:%a %H:%M}"
    if now - slot > LATE:
        label += f" → {now:%H:%M}"

    workspace = scheduled_workspace()
    if workspace is None:
        created = herdr(
            "workspace",
            "create",
            "--cwd",
            str(task.cwd),
            "--label",
            WORKSPACE,
            "--no-focus",
        )
        herdr("tab", "rename", created["tab"]["tab_id"], label)
    else:
        created = herdr(
            "tab",
            "create",
            "--workspace",
            workspace,
            "--cwd",
            str(task.cwd),
            "--label",
            label,
            "--no-focus",
        )

    # Typed into the pane's own shell, so pi gets your interactive environment. The
    # prompt goes through a file so it needs no quoting.
    command = ["pi", "--name", f"{task.id} {slot:%Y-%m-%d %H:%M}"]
    if task.model:
        command += ["--model", task.model]
    if task.tools:
        command += ["--tools", task.tools]
    line = f'{shlex.join(command)} "$(cat {shlex.quote(str(prompt_file))})"'
    herdr("pane", "run", created["root_pane"]["pane_id"], line)
    return created["tab"]["tab_id"]


def run(task: Task, slot: datetime, now: datetime, state: dict) -> bool:
    entry = state.setdefault(task.id, {})
    # Recorded even when the launch fails, so a broken task is reported once per slot
    # instead of being retried, and opening a tab, every minute.
    entry["last"] = now.timestamp()
    try:
        entry["tab"] = launch(task, slot, now)
    except (HerdrError, OSError) as error:
        entry["error"] = str(error)
        report(task.id, f"failed to start: {error}")
        return False
    else:
        entry.pop("error", None)
        log(f"started {task.id}")
        return True
    finally:
        save_state(state)


def log(message: str) -> None:
    print(f"{datetime.now():%Y-%m-%d %H:%M:%S} {message}", flush=True)


def report(task_id: str, message: str) -> None:
    log(f"{task_id}: {message}")
    script = f"display notification {json.dumps(message, ensure_ascii=False)} with title {json.dumps(f'pi-schedule: {task_id}')}"
    subprocess.run(["osascript", "-e", script], capture_output=True, check=False)


def tick(now: datetime) -> None:
    state = load_state()
    herdr_up = None
    for path in sorted(TASKS_DIR.glob("*.md")):
        entry = state.setdefault(path.stem, {})
        try:
            task = Task.load(path)
        except TaskError as error:
            # Reported once per version of the file, not every minute.
            written = path.stat().st_mtime
            if entry.get("invalid") != written:
                entry["invalid"] = written
                save_state(state)
                report(path.stem, str(error))
            continue
        if entry.pop("invalid", None) is not None:
            save_state(state)

        slot = task.due(last_run(entry), now)
        if slot is None:
            continue
        if herdr_up is None:
            herdr_up = herdr_running()
        if not herdr_up:
            return  # Due tasks stay due; a later tick starts them once Herdr runs.
        run(task, slot, now, state)


def fmt(moment: datetime | None) -> str:
    return f"{moment:%a %Y-%m-%d %H:%M}" if moment else "-"


def list_tasks(now: datetime) -> int:
    state = load_state()
    invalid = 0
    for path in sorted(TASKS_DIR.glob("*.md")):
        entry = state.get(path.stem, {})
        try:
            task = Task.load(path)
        except TaskError as error:
            print(f"{path.stem:28} invalid: {error}")
            invalid += 1
            continue
        last = last_run(entry)
        if not task.enabled:
            upcoming = "paused"
        elif task.due(last, now):
            upcoming = "due, starts once Herdr is running"
        else:
            upcoming = fmt(task.schedule.next(now))
        failed = f"  failed: {entry['error']}" if "error" in entry else ""
        print(
            f"{task.id:28} {task.schedule.text:24} last: {fmt(last):20} next: {upcoming}{failed}"
        )
    return 1 if invalid else 0


def clean(now: datetime) -> None:
    """Closes scheduled tabs whose run has finished and been seen."""
    workspace = scheduled_workspace()
    if workspace is None:
        return
    starting = {
        entry["tab"]
        for entry in load_state().values()
        if "tab" in entry and now - datetime.fromtimestamp(entry["last"]) < STARTUP
    }
    tabs: dict[str, list[dict]] = {}
    for pane in herdr("pane", "list", "--workspace", workspace)["panes"]:
        tabs.setdefault(pane["tab_id"], []).append(pane)
    # `idle` is a finished agent you have looked at; unseen results are `done`.
    for tab, panes in tabs.items():
        if tab in starting:
            continue
        if all(p.get("agent") is None or p["agent_status"] == "idle" for p in panes):
            herdr("tab", "close", tab)
            print(f"closed {tab}")


def main(argv: list[str]) -> int:
    now = datetime.now()
    match argv:
        case ["tick"]:
            tick(now)
        case ["list"]:
            return list_tasks(now)
        case ["clean"]:
            clean(now)
        case ["run", task_id]:
            path = TASKS_DIR / f"{task_id}.md"
            if not path.exists():
                print(f"no task {task_id!r} in {TASKS_DIR}", file=sys.stderr)
                return 1
            try:
                task = Task.load(path)
            except TaskError as error:
                print(f"{task_id}: {error}", file=sys.stderr)
                return 1
            if not herdr_running():
                print("Herdr is not running", file=sys.stderr)
                return 1
            return 0 if run(task, now, now, load_state()) else 1
        case _:
            print("usage: pi-schedule list | run <id> | clean | tick", file=sys.stderr)
            return 2
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
