#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$REPO_DIR/commands/install-commands.sh"
"$REPO_DIR/skills/install-skills.sh"
