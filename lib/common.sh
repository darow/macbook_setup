#!/bin/bash
# Shared helpers for macbook_setup scripts.
# Source from repo-root scripts:
#   source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log_ok()   { echo "✔ $*"; }
log_info() { echo "→ $*"; }
log_warn() { echo "⚠️  $*"; }
log_err()  { echo "❌ $*"; }

# Append a multi-line block to a file if <match> is not already present.
# Usage: ensure_line_in_file <file> <match> <line...>
ensure_line_in_file() {
    local file="$1"
    local match="$2"
    shift 2

    touch "$file"
    if grep -qF "$match" "$file" 2>/dev/null; then
        return 1
    fi

    {
        echo ""
        printf '%s\n' "$@"
    } >> "$file"
    return 0
}

# Print the newest GoLand settings directory under JetBrains Application Support, or empty.
find_goland_dir() {
    local jetbrains_dir="$HOME/Library/Application Support/JetBrains"
    if [ ! -d "$jetbrains_dir" ]; then
        return 0
    fi
    find "$jetbrains_dir" -maxdepth 1 -type d -name "GoLand*" 2>/dev/null | sort -V | tail -n 1
}

# Activate Homebrew for the current shell (Apple Silicon default prefix).
require_brew() {
    if [ -x "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    if ! command -v brew >/dev/null 2>&1; then
        log_err "Homebrew не установлен."
        return 1
    fi
}
