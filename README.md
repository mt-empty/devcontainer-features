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
