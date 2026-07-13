# devcontainer-features

Custom [Dev Container Features](https://containers.dev/implementors/features/) for personal use.

## Features

### `my-cli-tools`

Installs a common set of CLI tools into any dev container:

| Tool | Purpose |
|---|---|
| `fzf` | Fuzzy finder |
| `zoxide` | Smarter `cd` |
| `gh` | GitHub CLI |
| `jq` | JSON processor |
| `yq` | YAML/JSON processor |
| `eza` | Modern `ls` |
| `bat` | `cat` with syntax highlighting |
| `ripgrep` | Fast `grep` |
| `fd` | Fast `find` |
| `tmux` | Terminal multiplexer |
| `curl`, `wget`, `netcat` | Network tools |
| `opencode` | AI coding agent CLI |
| `gh copilot` | GitHub Copilot CLI extension |

**Usage in `devcontainer.json`:**

```json
"features": {
    "ghcr.io/mt-empty/devcontainer-features/my-cli-tools:1": {}
}
```

**Options:**

| Option | Default | Description |
|---|---|---|
| `installZoxide` | `true` | Install zoxide |
| `installYq` | `true` | Install yq |
| `installOpencode` | `true` | Install opencode CLI |
| `installGhCopilot` | `true` | Install gh copilot extension |

### `dotfiles`

Clones [mt-empty/dotfiles](https://github.com/mt-empty/dotfiles) and runs its
`install_devcontainer.sh`. Hardcoded to this one repo on purpose — it's a
personal feature, not a generic reusable one, so there's no options schema to
keep in sync with the dotfiles repo.

The clone+run step is this feature's `postCreateCommand`, not `install.sh`.
`install.sh` only ensures `git` is present at build time — it never touches the
dotfiles repo, so it's cache-safe. The actual `git clone`/`fetch` happens live,
every time a container is *created*, as a metadata-driven lifecycle command
rather than a cached Docker `RUN` layer. That means pushing a new commit to the
dotfiles repo is picked up on the next container/rebuild with zero changes
needed here — no version bump, no cache-busting.

Note: `postCreateCommand` runs when a container is *created* (fresh `up` or
"Rebuild Container"), not on every plain start/attach of an already-running
container. Rebuild when you want the latest dotfiles pulled in.

**Usage in `devcontainer.json`:**

```json
"features": {
    "ghcr.io/mt-empty/devcontainer-features/dotfiles:2": {}
}
```

No options — it always clones `mt-empty/dotfiles@master` and runs
`install_devcontainer.sh`.

Also bind-mounts the host's `~/.gitconfig` at `/etc/host-gitconfig` (the Feature
mount schema has no read-only option, but nothing here ever writes to it — only
`git config -f /etc/host-gitconfig --get ...` reads happen). Not `/tmp`:
`docker-in-docker` runs privileged and its init remounts a fresh tmpfs over
`/tmp`, silently shadowing anything bind-mounted underneath it — confirmed via
a full integration test using this repo's actual feature set together.
`install_devcontainer.sh`'s tracked `.gitconfig` defers identity to a
git-ignored `~/.gitconfig.local`, and this mount lets it seed that file from
your real host identity on first run — verified empirically that VS Code's own
"copy .gitconfig into the container" behavior does *not* reliably populate
`$HOME/.gitconfig` before this feature's `postCreateCommand` runs, so this
mount exists specifically to not depend on that.

### `shell-history`

Mounts a Docker volume at `/commandhistory` and sets `HISTFILE` to
`/commandhistory/.zsh_history`, so shell history survives "Rebuild Container"
instead of being lost with the old container.

The volume is named `shellhistory-${devcontainerId}` — `devcontainerId` is a
hash of the project's devcontainer config, so each project gets its own
isolated volume rather than one history shared across every devcontainer.
Verified with two separate configs producing two distinct volumes, and a
container remove+recreate against the same config reattaching the same volume
with prior history intact.

Only wires up zsh's `HISTFILE`; bash's history mechanism needs `PROMPT_COMMAND`
instead (see [VS Code's docs](https://code.visualstudio.com/remote/advancedcontainers/persist-bash-history)) and isn't handled by this feature.

**Usage in `devcontainer.json`:**

```json
"features": {
    "ghcr.io/mt-empty/devcontainer-features/shell-history:1": {}
}
```

No options.
