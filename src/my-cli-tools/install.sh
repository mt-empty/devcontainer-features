#!/bin/bash
set -e

INSTALL_ZOXIDE="${INSTALLZOXIDE:-true}"
INSTALL_YQ="${INSTALLYQ:-true}"
INSTALL_OPENCODE="${INSTALLOPENCODE:-true}"
INSTALL_GH_COPILOT="${INSTALLGHCOPILOT:-true}"

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
    curl -fsSL "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" \
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
    curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# yq
if [ "${INSTALL_YQ}" = "true" ] && ! command -v yq &>/dev/null; then
    echo ">>> Installing yq..."
    YQ_VERSION=$(curl -fsSL https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r '.tag_name')
    curl -fsSL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" \
        -o /usr/local/bin/yq
    chmod +x /usr/local/bin/yq
fi

# opencode — AI coding agent CLI
if [ "${INSTALL_OPENCODE}" = "true" ] && ! command -v opencode &>/dev/null; then
    echo ">>> Installing opencode..."
    curl -fsSL https://opencode.ai/install | bash
fi

# gh copilot extension
if [ "${INSTALL_GH_COPILOT}" = "true" ] && command -v gh &>/dev/null; then
    echo ">>> Installing gh copilot extension..."
    gh extension install github/gh-copilot --force || true
fi

echo ">>> my-cli-tools installation complete."
