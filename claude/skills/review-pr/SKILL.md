---
name: review-pr
description: Review a GitHub PR with parallel agents and post findings as a review
---
1. Run `gh pr view $ARGUMENTS --json headRefOid,files,body` and use the FULL headRefOid SHA for any API calls.
2. Check out the PR. Run the repo's lint/type/syntax checks (pre-commit run --all-files, ansible-playbook --syntax-check, etc.).
3. Spawn 3 parallel agents: correctness/security, tests/edge cases, conventions/simplicity.
4. Verify each finding against the code before including it. Drop anything unverified.
5. Group the findings into Critical / Important / Nits.
6. Show me the draft, then post it with `gh api` as a review with inline comments.
7. Offer to fix Critical/Important items and file an issue for out-of-scope ones.
