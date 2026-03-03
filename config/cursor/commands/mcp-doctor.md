# mcp-doctor

Diagnose why MCP servers are unavailable or failing.

1. Inspect config files:
   - `.cursor/mcp.json`
   - `~/.cursor/mcp.json`
2. Run `agent mcp list` and identify failing servers.
3. For each failing server, check:
   - command/package resolution
   - auth requirements
   - required env vars
4. Return exact, minimal fix steps and re-check commands.
