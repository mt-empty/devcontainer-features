#!/bin/bash
# Required entrypoint file — the devcontainer CLI hard-fails without one, even
# though this feature does no dotfiles-specific work at build time. All of that
# is deferred to postCreateCommand (see devcontainer-feature.json), which runs
# live against the container instead of a cached Docker layer, and shells out
# straight to mt-empty/dotfiles' own install_devcontainer.sh — nothing about the
# bootstrap steps is duplicated here.
set -eo pipefail

if ! command -v git &>/dev/null; then
    echo ">>> Installing git..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y --no-install-recommends git
fi
