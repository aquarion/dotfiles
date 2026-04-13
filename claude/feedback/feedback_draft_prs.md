---
name: Create PRs as draft by default
description: Always use --draft flag when creating PRs with gh pr create
type: feedback
---

Always create pull requests as drafts by default using `gh pr create --draft`.

**Why:** User preference — drafts signal work-in-progress and avoid premature review requests.

**How to apply:** Add `--draft` to every `gh pr create` invocation unless the user explicitly asks for a ready-for-review PR.
