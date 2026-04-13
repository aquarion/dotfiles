---
name: Run pre-commit before committing
description: Always run pre-commit manually before git commit to avoid the hook failing and requiring a second commit
type: feedback
---

Run `pre-commit run --files <staged files>` before `git commit` to catch linting fixes (Laravel Pint etc.) upfront. Re-stage any modified files before committing.

**Why:** Pre-commit hooks auto-fix files and abort the commit, requiring a second commit just to include the linter's changes. Running it first avoids that.

**How to apply:** Before every `git commit`, run `pre-commit run --files` on the files being staged. Re-stage if anything was modified, then commit.
