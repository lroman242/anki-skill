#!/usr/bin/env bash
# Delete an Anki note (and all its cards) by note ID.
# Usage: ./delete_card.sh --id 1502298033753
set -euo pipefail

ANKI_URL="http://localhost:8765"
note_id=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --id) note_id="$2"; shift 2 ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
    esac
done

if [[ -z "$note_id" ]]; then
    echo "Usage: $0 --id NOTE_ID"
    exit 1
fi

response=$(curl -sf -X POST "$ANKI_URL" \
    -H "Content-Type: application/json" \
    -d "{\"action\":\"deleteNotes\",\"version\":6,\"params\":{\"notes\":[$note_id]}}")

error=$(printf '%s' "$response" | sed -n 's/.*"error": *"\([^"]*\)".*/\1/p')
if [[ -n "$error" ]]; then
    echo "Error: $error"
    exit 1
fi

echo "Note $note_id deleted."
