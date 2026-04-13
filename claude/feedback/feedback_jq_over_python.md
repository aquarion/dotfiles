---
name: Prefer jq over Python for JSON parsing in shell
description: Use jq instead of python3 -c for parsing JSON in bash commands
type: feedback
originSessionId: bda131e2-27d0-44ba-b03f-f07edf7aae7d
---
Use `jq` instead of `python3 -c` for parsing JSON in shell commands.

**Why:** More idiomatic for shell JSON processing — user preference.

**How to apply:** Whenever parsing JSON output from a tool result or CLI command in a Bash call, reach for `jq` first.
