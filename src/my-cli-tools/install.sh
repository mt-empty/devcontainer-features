#!/bin/bash
set -eo pipefail

INSTALL_ZOXIDE="${INSTALLZOXIDE:-true}"
INSTALL_YQ="${INSTALLYQ:-true}"
INSTALL_OPENCODE="${INSTALLOPENCODE:-true}"

echo ">>> Installing base CLI tools..."

export DEBIAN_FRONTEND=noninteractive

apt-get update -y

# Core tools available in apt
apt-get install -y --no-install-recommends \
    curl \
    wget \
    netcat-openbsd \
    fzf \
    ripgrep \
    bat \
    jq \
    fd-find

# eza — not in apt on Debian/Ubuntu <24.04, install from GitHub release
if ! command -v eza &>/dev/null; then
    echo ">>> Installing eza..."
    EZA_VERSION=$(curl -fsSL https://api.github.com/repos/eza-community/eza/releases/latest | jq -r '.tag_name')
    if [ -z "${EZA_VERSION}" ] || [ "${EZA_VERSION}" = "null" ]; then
        echo "ERROR: Could not determine eza version (GitHub API rate limit?)" >&2; exit 1
    fi
    # Map dpkg arch (amd64/arm64) to eza's GNU triple naming
    case "$(dpkg --print-architecture)" in
        amd64) EZA_ARCH="x86_64-unknown-linux-gnu" ;;
        arm64) EZA_ARCH="aarch64-unknown-linux-gnu" ;;
        *)     echo "Unsupported architecture for eza: $(dpkg --print-architecture)"; exit 1 ;;
    esac
    curl -fsSL "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_${EZA_ARCH}.tar.gz" \
        | tar -xz -C /usr/local/bin eza
    chmod +x /usr/local/bin/eza
fi

# bat is installed as batcat on Debian/Ubuntu — create alias
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    ln -sf "$(command -v batcat)" /usr/local/bin/bat
fi

# fd is installed as fdfind on Debian/Ubuntu — create alias
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    ln -sf "$(command -v fdfind)" /usr/local/bin/fd
fi

# gh — GitHub CLI (official apt source)
if ! command -v gh &>/dev/null; then
    echo ">>> Installing gh (GitHub CLI)..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list
    apt-get update -y
    apt-get install -y gh
fi

# zoxide
if [ "${INSTALL_ZOXIDE}" = "true" ] && ! command -v zoxide &>/dev/null; then
    echo ">>> Installing zoxide..."
    # Force install to /usr/local/bin so it is on PATH for all users, not just root.
    curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | BINDIR=/usr/local/bin bash
fi

# yq
if [ "${INSTALL_YQ}" = "true" ] && ! command -v yq &>/dev/null; then
    echo ">>> Installing yq..."
    YQ_VERSION=$(curl -fsSL https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r '.tag_name')
    if [ -z "${YQ_VERSION}" ] || [ "${YQ_VERSION}" = "null" ]; then
        echo "ERROR: Could not determine yq version (GitHub API rate limit?)" >&2; exit 1
    fi
    # yq release names use dpkg-style arch (amd64, arm64) — matches dpkg --print-architecture directly
    curl -fsSL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_$(dpkg --print-architecture)" \
        -o /usr/local/bin/yq
    chmod +x /usr/local/bin/yq
fi

# opencode — AI coding agent CLI
if [ "${INSTALL_OPENCODE}" = "true" ] && ! command -v opencode &>/dev/null; then
    echo ">>> Installing opencode..."
    curl -fsSL https://opencode.ai/install | bash
    # Installer puts binary in $HOME/.opencode/bin (resolves to /root/.opencode/bin when
    # run as root during image build). Move it to a system-wide location so all users can
    # access it.
    if [ -f /root/.opencode/bin/opencode ]; then
        mv /root/.opencode/bin/opencode /usr/local/bin/opencode
    else
        echo "ERROR: opencode binary not found at /root/.opencode/bin/opencode after install" >&2
        exit 1
    fi
    command -v opencode >/dev/null || { echo "ERROR: opencode not on PATH after install" >&2; exit 1; }
fi

echo ">>> my-cli-tools installation complete."
