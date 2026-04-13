# dotfiles

Personal dotfiles for bash, git, vim, SSH, and related tools.

## Installation

```bash
./install.sh [hostname]
```

Creates symlinks from `~` into this repository. If `hostname` is omitted it defaults to `$(hostname)`. Existing files are backed up as `<file>.orig.<date>` before being replaced.

The following symlinks are created:

| Target | Source |
|--------|--------|
| `~/.bash_profile` | `bash/bash_profile.bash` |
| `~/.bash_profile.local` | `bash/bash_profile.<hostname>.bash` (if it exists) |
| `~/.bashrc` | `bash/bashrc` |
| `~/.gitconfig` | `gitconfig` |
| `~/.git-prompt.bash` | `bash/git_prompt.bash` |
| `~/.vimrc` | `vimrc` |
| `~/.ssh/config` | `ssh-config` |
| `~/.direnvrc` | `direnvrc` |

SSH `authorized_keys` from `ssh/authorized_keys.d/` are merged into `~/.ssh/authorized_keys` (deduped).

## Bash profile

`bash/bash_profile.bash` is the main login shell config. It runs in order:

**Bootstrapping**
- Sources `~/.bashrc` if present
- Aliases `sed` to `gsed` on macOS if available
- Locates the dotfiles directory and exports it as `$MYDIR`
- Sources the git completion, colour, and function libraries

**Environment**
- Sets `$ARCH` (`darwin-amd64`, `linux-amd64`, or `linux-386`) based on `uname`
- Sets `$EDITOR` to `code -w` inside VS Code terminals (`$TERM_PROGRAM=vscode`), otherwise `vim`; locale to `en_GB`; history limits to 100k commands
- Enables coloured `ls` output

**PATH construction**

Adds the following directories to `PATH` if they exist, in order:
`~/bin`, `~/.local/bin`, MacPorts (`/opt/local`), Homebrew (`/opt/homebrew` or `/home/linuxbrew`), Composer global bin, AWS CLI, VS Code CLI, `$MYDIR/bin`

At the end of startup, `PATH` is deduplicated (non-existent directories removed, duplicates dropped) and saved as `$CLEAN_PATH`.

**Shell completions**

Loads bash completion from Homebrew, `/etc/bash_completion`, or the bundled git completion, whichever is found first.

**Prompt**

The prompt (`$PS1`) is two lines:

```
<user>@<host> [🧊kube-context] [gcloud-project] <aws-session> (<git-branch>)
<cwd> $
```

- Git branch is colour-coded: yellow for unstaged changes, purple for staged, cyan for clean
- Kubernetes context is read directly from `~/.kube/config`
- GCloud project is read from the active gcloud configuration
- AWS session info is fetched via a Python helper (`aws/aws_session__ps1.py`) and cached for 30 seconds per profile

On each prompt (`PROMPT_COMMAND`), `PATH` is also updated to prepend the current project's Composer `bin-dir` or npm bin directory if applicable, and the virtualenv bin if one is active.

**Tool integrations**

Loaded if present: RVM, NVM, virtualenvwrapper, direnv, ngrok shell completion

**Per-host config**

Sources `~/.bash_profile.local` at the end of startup if it exists (installed from `bash/bash_profile.<hostname>.bash`).

## Per-host configuration

Host-specific bash config lives in `bash/bash_profile.<hostname>.bash` and is symlinked to `~/.bash_profile.local`, which is sourced at the end of `bash_profile.bash`. Hosts with existing files: `cyclone`, `sirocco`, `waterwheel`.

## Shell functions

Defined in `bash/lib/functions.lib.bash` and sourced into every session.

| Function | Description |
|----------|-------------|
| `c <name>` | `pushd` into the first matching directory under `~/code/` (depth 1) |
| `p <name>` | `pushd` into the first matching directory under `~/code/`, searching depths 2–5 |
| `h <name>` | `pushd` into the first matching directory under `~/hosts/` |
| `f <name>` | Find a file or directory in the current tree and `pushd` into it (or its parent) |
| `cdd <path>` | `pushd` into the parent directory of a file path |
| `switchenv` | Switch between `production` and `staging` by swapping the path component |
| `find-up <name>` | Walk up the directory tree looking for a file, print its relative path |
| `viewssl <host> [port]` | Display the TLS certificate for a host (default port 443) |
| `random_words [n]` | Print *n* random words from the system dictionary (default 2) |
| `dockexec <container> [cmd]` | Run a command in a Docker container, mapping the current path into `/var/www/hosts` |
| `miscwebexec [cmd]` | Shortcut for `dockexec miscweb` |

## Code quality

[pre-commit](https://pre-commit.com/) is configured to run on every commit:

- **shellcheck** — shell script linting
- **trailing-whitespace** — strips trailing whitespace
- **end-of-file-fixer** — ensures files end with a newline
- **check-yaml** — YAML syntax validation
- **check-added-large-files** — prevents accidentally committing large files

To install the hooks after cloning:

```bash
pre-commit install
```
