#!/bin/bash
# Required entrypoint file — the devcontainer CLI hard-fails without one, even
# though this feature does no work at build time. Everything happens live
# against the running container via mounts/containerEnv/postCreateCommand in
# devcontainer-feature.json instead, since the mount doesn't exist yet at
# image-build time.
set -eo pipefail

echo ">>> shell-history feature: nothing to do at build time."
