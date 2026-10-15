import os
import tempfile
import unittest
from datetime import datetime
from pathlib import Path

from pi_schedule import Schedule, Task, TaskError

# Thursday.
NOW = datetime(2026, 10, 15, 11, 30)


class ScheduleTest(unittest.TestCase):
    def test_daily_last_is_today_once_passed(self):
        self.assertEqual(
            Schedule.parse("daily 09:00").last(NOW), datetime(2026, 10, 15, 9, 0)
        )

    def test_daily_last_is_yesterday_before_slot(self):
        self.assertEqual(
            Schedule.parse("daily 12:00").last(NOW), datetime(2026, 10, 14, 12, 0)
        )

    def test_weekdays_skip_the_weekend(self):
        monday = datetime(2026, 10, 19, 8, 0)
        self.assertEqual(
            Schedule.parse("weekdays 09:00").last(monday), datetime(2026, 10, 16, 9, 0)
        )
        self.assertEqual(
            Schedule.parse("weekdays 09:00").next(datetime(2026, 10, 16, 10, 0)),
            monday.replace(hour=9),
        )

    def test_day_list(self):
        schedule = Schedule.parse("mon,thu 18:30")
        self.assertEqual(schedule.last(NOW), datetime(2026, 10, 12, 18, 30))
        self.assertEqual(schedule.next(NOW), datetime(2026, 10, 15, 18, 30))

    def test_slot_exactly_now_is_due(self):
        self.assertEqual(Schedule.parse("daily 11:30").last(NOW), NOW)

    def test_once(self):
        schedule = Schedule.parse("once 2026-10-15 09:00")
        self.assertEqual(schedule.last(NOW), datetime(2026, 10, 15, 9, 0))
        self.assertIsNone(schedule.next(NOW))
        self.assertIsNone(Schedule.parse("once 2026-10-16 09:00").last(NOW))

    def test_slots_keep_wall_clock_time_across_dst(self):
        # Europe ends DST on 2026-10-25; a daily 09:00 stays 09:00 on both sides.
        after = datetime(2026, 10, 26, 8, 0)
        self.assertEqual(
            Schedule.parse("daily 09:00").last(after), datetime(2026, 10, 25, 9, 0)
        )

    def test_invalid(self):
        for text in [
            "",
            "daily",
            "daily 9:00",
            "daily 25:00",
            "sometimes 09:00",
            "mon,funday 09:00",
            "once 2026-13-01 09:00",
        ]:
            with self.subTest(text=text), self.assertRaises(TaskError):
                Schedule.parse(text)


class TaskTest(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.TemporaryDirectory()
        self.root = Path(self.dir.name)

    def tearDown(self):
        self.dir.cleanup()

    def write(self, text: str, written: datetime = datetime(2026, 10, 1)) -> Path:
        path = self.root / "task.md"
        path.write_text(text)
        os.utime(path, (written.timestamp(), written.timestamp()))
        return path

    def task(self, schedule: str, written: datetime = datetime(2026, 10, 1)) -> Task:
        return Task.load(
            self.write(
                f"---\nschedule: {schedule}\ncwd: {self.root}\n---\nDo it.\n", written
            )
        )

    def test_load(self):
        path = self.write(
            f'---\nschedule: "daily 09:00"\ncwd: {self.root}\nmodel: claude-haiku-5-5\n---\n\nDo it.\n'
        )
        task = Task.load(path)
        self.assertEqual(task.id, "task")
        self.assertEqual(task.schedule.text, "daily 09:00")
        self.assertEqual(task.model, "claude-haiku-5-5")
        self.assertIsNone(task.tools)
        self.assertEqual(task.prompt, "Do it.\n")

    def test_load_rejects_mistakes(self):
        cases = {
            "unknown key": "---\nschedule: daily 09:00\nmodle: x\n---\nDo it.\n",
            "missing schedule": "---\ncwd: ~\n---\nDo it.\n",
            "missing cwd": "---\nschedule: daily 09:00\ncwd: /no/such/dir\n---\nDo it.\n",
            "empty prompt": "---\nschedule: daily 09:00\n---\n\n",
            "no frontmatter": "schedule: daily 09:00\nDo it.\n",
            "bad enabled": "---\nschedule: daily 09:00\nenabled: no\n---\nDo it.\n",
        }
        for name, text in cases.items():
            with self.subTest(name), self.assertRaises(TaskError):
                Task.load(self.write(text))

    def test_due_after_last_run(self):
        task = self.task("daily 09:00")
        self.assertEqual(
            task.due(datetime(2026, 10, 14, 9, 0), NOW), datetime(2026, 10, 15, 9, 0)
        )
        self.assertIsNone(task.due(datetime(2026, 10, 15, 9, 1), NOW))

    def test_missed_slots_run_once(self):
        task = self.task("daily 09:00")
        self.assertEqual(
            task.due(datetime(2026, 10, 1, 9, 0), NOW), datetime(2026, 10, 15, 9, 0)
        )

    def test_new_recurring_task_waits_for_a_slot_after_it_was_written(self):
        self.assertIsNone(
            self.task("daily 09:00", written=datetime(2026, 10, 15, 10, 0)).due(
                None, NOW
            )
        )
        self.assertEqual(
            self.task("daily 09:00", written=datetime(2026, 10, 15, 8, 58)).due(
                None, NOW
            ),
            datetime(2026, 10, 15, 9, 0),
        )

    def test_once_fires_even_when_written_after_its_time(self):
        task = self.task("once 2026-10-15 09:00", written=datetime(2026, 10, 15, 10, 0))
        self.assertEqual(task.due(None, NOW), datetime(2026, 10, 15, 9, 0))
        self.assertIsNone(task.due(NOW, NOW))

    def test_paused_task_is_never_due(self):
        path = self.write(
            f"---\nschedule: daily 09:00\ncwd: {self.root}\nenabled: false\n---\nDo it.\n"
        )
        self.assertIsNone(Task.load(path).due(None, NOW))


if __name__ == "__main__":
    unittest.main()
