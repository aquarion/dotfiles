# Claude Development Guidelines

Guidelines for Claude when working on this repository to avoid common mistakes and improve code quality.

## Tool Use

- If you have jq, yq & htmlq available, use them in preference to python scripts
- Always use the Write tool to create or edit files. Never use sed, cat, or shell commands for file editing

## Pre-Implementation Validation

### Always Do First
1. **Read the complete file context** before making any edits
2. **Understand the full workflow/logic** before implementing pieces
3. **Map out the complete sequence** of operations needed
4. **Identify dependencies** - what needs to happen before what?

### YAML/GitHub Actions Specific
- **Validate YAML syntax** mentally - check indentation, quotes, structure
- **Verify permissions against known valid values** - don't guess at GitHub Actions permissions
- **Check conditional logic** syntax (`${{ }}` expressions)
- **Ensure consistent indentation** (spaces vs tabs)

### Self-Checking Questions
Before submitting any change, ask:
- "Does this look syntactically correct?"
- "Are these GitHub Actions permissions actually valid?"
- "Does this logical sequence make sense end-to-end?"
- "Have I left any remnants from previous edits?"
- "Am I working reactively or have I planned this through?"

## Better Development Process

### Planning Phase
1. **Architecture first** - "What's the complete workflow from start to finish?"
2. **Consider edge cases** - "What could go wrong and how should we handle it?"
3. **Clean slate approach** - Sometimes start fresh instead of iterative fixes
4. **Validate assumptions** against documentation

### Implementation Phase
1. **Use multi_replace_string_in_file** for multiple related changes
2. **Read full context** before editing any file
3. **Clean up thoroughly** after each change
4. **Test logical flow** mentally before submitting

### Review Phase
1. **Review my own work** before the user sees it
2. **Explain reasoning** when implementing complex changes
3. **Validate final result** meets the original requirements

## Common Mistake Patterns to Avoid

### GitHub Actions Workflows
- ❌ Invalid permissions (like `actions: read`, `metadata: read`)
- ❌ Redundant checkout/update steps when `actions/checkout@v4` handles it
- ❌ Poor step ordering (validate early, fail fast)
- ❌ Unnecessary validation steps that Git handles naturally
- ❌ YAML indentation errors

### General Development
- ❌ Making changes without understanding the full context
- ❌ Leaving old code fragments after edits
- ❌ Working reactively instead of planning ahead
- ❌ Not validating syntax before submitting

## Development Preferences

### Git Commits:

- Prefix with an emoji:
 - 🧵 for linting/style fixes
 - 🪳 for bug fixes
 - 🎇 for new features
 - ❌ for removed features
 - 🔄️ for changes
 - 🐦‍🔥 for upgrades
 - 🖼️ for UI changes
 - 📖 for documentation/instruction changes
 - ⚙️ for deployment/CI changes

## Branching Strategy

- *Never Commit To Main* — this applies to ALL repos, including support/infrastructure repos like Ansible playbooks. Always check the current branch before committing in every repo touched during a task.
- Commit to a feature, bugfix, or release branch.
- Always create pull requests as drafts by default using `gh pr create --draft`.

## Other Feedback

- There's a feedback directory in ~/code/dotfiles/claude/feedback with more things, please read it.

## Collaborative Improvements

### Request from User
- Call out repeated mistake patterns
- Ask for reasoning explanation before complex implementations
- Request self-review/validation before user review
- When uncertain about what the user means or intends, ask them directly rather than making assumptions and proceeding.

### From Claude
- Think through complete solution before starting
- Validate against documentation when uncertain
- Clean up thoroughly after each change
- Explain architectural decisions clearly

## Branch Safety
- NEVER commit directly to main/master. Always verify current branch with `git branch --show-current` before committing.
- After a PR merges, explicitly checkout main and pull, then create a new feature branch before any further work.
- Before committing to any pre-existing branch, verify it is the correct branch for the current task (check recent commits and branch name relevance).

# Workflow

## Verification Before Claiming Success
- Always run tests after making code changes before reporting a fix as complete.
- Do not assume a fix works without executing it; run the relevant test/lint/build command and show output.
- When unsure about scope (e.g., 'fix bug X'), ask clarifying questions instead of guessing the narrowest interpretation.

# CI / GitHub Actions

- Always include explicit `permissions:` blocks (contents:read at minimum) in workflows.
- The default GITHUB_TOKEN cannot access the variables/environments API or merge PRs — use a PAT for those.
- Do not use `--offline` with ansible-lint in CI.
- When editing shared-workflows, ensure consumer repos still pass: bootstrap/cache directories, migrate steps for Dusk, and avoid `environment:` keys that trigger deployments.

---

*This document serves as a reminder to maintain higher standards and avoid the basic errors that slow down development.*
