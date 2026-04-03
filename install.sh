#!/bin/bash
# nav installer

set -e

REPO="fattarsi/nav"
INSTALL_DIR="${INSTALL_DIR:-$HOME/bin}"
SHELL_NAME=$(basename "$SHELL")

mkdir -p "$INSTALL_DIR"

# If nav script exists locally (cloned repo), copy it. Otherwise fetch from GitHub.
if [ -f "$(dirname "$0")/nav" ]; then
    cp "$(dirname "$0")/nav" "$INSTALL_DIR/nav"
else
    curl -fsSL "https://raw.githubusercontent.com/$REPO/main/nav" -o "$INSTALL_DIR/nav"
fi
chmod +x "$INSTALL_DIR/nav"

WRAPPER='
# nav - fuzzy file browser (cd to final directory on exit)
n() {
    local result dest
    result=$(nav)
    if [[ "$result" == *$'"'"'\n'"'"'* ]]; then
        local last_line="${result##*$'"'"'\n'"'"'}"
        local first_line="${result%%$'"'"'\n'"'"'*}"
        if [[ "$first_line" == OPEN:* ]]; then
            ${EDITOR:-vim} "${first_line#OPEN:}"
            return
        fi
        dest="$last_line"
    else
        dest="$result"
    fi
    if [ -n "$dest" ] && [ "$dest" != "$PWD" ]; then
        builtin cd -- "$dest"
    fi
}'

case "$SHELL_NAME" in
    zsh)  RC_FILE="$HOME/.zshrc" ;;
    bash) RC_FILE="$HOME/.bashrc" ;;
    *)    RC_FILE="" ;;
esac

if [ -n "$RC_FILE" ]; then
    if grep -q 'function n()' "$RC_FILE" 2>/dev/null || grep -q 'n()' "$RC_FILE" 2>/dev/null; then
        echo "shell wrapper for n() already exists in $RC_FILE — skipping"
    else
        echo "$WRAPPER" >> "$RC_FILE"
        echo "added n() wrapper to $RC_FILE"
    fi
else
    echo "unknown shell ($SHELL_NAME) — add the wrapper function manually (see README)"
fi

if echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    echo "installed nav to $INSTALL_DIR/nav"
else
    echo "installed nav to $INSTALL_DIR/nav"
    echo "NOTE: $INSTALL_DIR is not in your PATH — add it:"
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi

echo "restart your shell or run: source $RC_FILE"
