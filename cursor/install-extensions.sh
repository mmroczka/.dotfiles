#!/usr/bin/env bash
# Install Cursor extensions from extensions.txt
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_FILE="$SCRIPT_DIR/extensions.txt"

if ! command -v cursor &> /dev/null; then
    echo "cursor CLI not found, skipping extension install"
    exit 0
fi

if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "extensions.txt not found at $EXTENSIONS_FILE"
    exit 1
fi

while IFS= read -r extension; do
    [ -z "$extension" ] && continue
    cursor --install-extension "$extension" --force
done < "$EXTENSIONS_FILE"
