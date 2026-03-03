# mcp-reference

Review and validate the enabled MCP reference server setup.

1. Run `agent mcp list`.
2. Verify these servers are configured and reachable:
   - `fetch`
   - `filesystem`
   - `git`
   - `memory`
   - `sequential-thinking`
   - `time`
3. For connected servers, run `agent mcp list-tools <identifier>`.
4. Summarize:
   - Missing or failing reference servers
   - Likely root causes (auth, package, path scope, env vars)
   - Minimal remediation steps
