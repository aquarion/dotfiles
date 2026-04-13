---
name: Verify before committing
description: Test/verify logic and commands before committing — don't assume correctness
type: feedback
---

Verify that things actually work before committing — this applies to CLI commands, logic, cache key interactions, anything non-trivial. Don't assume a command has the flags you think it has, or that logic you wrote is correct without checking.

**Why:** Multiple incidents: (1) `gh pr view --state open` committed to a workflow without testing — `--state` is not a valid flag for `gh pr view`; (2) cache key throttle/trigger logic was wrong (monitor `pull` reset the cooldown window) — committed without verifying the interaction; (3) `gh api` command with shell interpolation error treated as success.

**How to apply:** Run CLI commands locally first. Trace through logic mentally (or with a test) before committing. If in doubt, test it — don't ship it and find out in CI or review.
