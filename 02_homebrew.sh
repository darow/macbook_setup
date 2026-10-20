#!/bin/bash

if command -v brew >/dev/null 2>&1; then
    echo "✔ Homebrew already installed."
else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

if command -v brew >/dev/null 2>&1; then
    echo "✔ Homebrew ready: $(brew --version | head -n1)"
else
    echo "❌ Homebrew install failed."
    exit 1
fi

# dockutil
if ! command -v dockutil >/dev/null 2>&1; then
    echo "Installing dockutil..."
    brew install dockutil
fi

if command -v dockutil >/dev/null 2>&1; then
    echo "✔ dockutil ready."
else
    echo "❌ dockutil install failed."
    exit 1
fi