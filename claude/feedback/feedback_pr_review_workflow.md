---
name: PR review workflow
description: When fixing PR review comments, also resolve the GitHub threads after fixing them
type: feedback
---

When the user asks to fix PR review comments, after making the fixes also resolve the corresponding GitHub review threads using the GraphQL API (`resolveReviewThread` mutation). Don't wait to be asked — resolving threads is part of the "fix PR comments" workflow.

**Don't auto-fix every comment.** Review comments are not automatically worth acting on. Apply judgement, and also check whether the user has replied to the thread — their reply is the strongest signal:
- User reply says "fix it" / "yes" / agrees → fix it
- User reply says "follow up feature" / "by design" / pushes back → skip it, thread is already resolved in spirit
- No user reply, comment flags a genuine bug or correctness issue → fix it
- No user reply, comment is stylistic or speculative → surface it for the user to decide

**Why:** User said "Review comments aren't automatically something that needs to be fixed (unless my comment says so), don't automatically fix things you don't think are worthwhile." and asked that their own replies on threads be factored in.

**Limitation:** The REST API (`gh api repos/.../pulls/.../comments`) returns all comments regardless of resolved state — there is no `resolved` field. This means you cannot tell which threads are already resolved. Only reply to / resolve threads for comments you have *just* acted on in the current session; don't re-address comments from a previous session that are likely already resolved.
