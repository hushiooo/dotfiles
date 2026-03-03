# mcp-status

Audit MCP availability and tool inventory.

1. Run `agent mcp list`.
2. For each connected server, run `agent mcp list-tools <identifier>`.
3. Summarize:
   - Connected vs disconnected servers
   - Top useful tools per server
   - Any auth/config issues blocking usage
