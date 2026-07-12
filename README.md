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
