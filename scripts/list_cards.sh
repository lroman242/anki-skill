#!/usr/bin/env bash
# List Anki cards via AnkiConnect. Outputs raw JSON.
# Usage:
#   ./list_cards.sh
#   ./list_cards.sh --deck "CS"
#   ./list_cards.sh --tag "python"
#   ./list_cards.sh --query "tag:python added:7"
set -euo pipefail

ANKI_URL="http://localhost:8765"
deck="" tag="" query=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --deck)  deck="$2";  shift 2 ;;
        --tag)   tag="$2";   shift 2 ;;
        --query) query="$2"; shift 2 ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
    esac
done

if [[ -z "$query" ]]; then
    parts=""
    [[ -n "$deck" ]] && parts="${parts} deck:\"$deck\""
    [[ -n "$tag"  ]] && parts="${parts} tag:$tag"
    query="${parts# }"
    [[ -z "$query" ]] && query="*"
fi

# Escape quotes in query for JSON embedding
query_json=$(printf '%s' "$query" | sed 's/\\/\\\\/g; s/"/\\"/g')

# Step 1: find note IDs
find_resp=$(curl -sf -X POST "$ANKI_URL" \
    -H "Content-Type: application/json" \
    -d "{\"action\":\"findNotes\",\"version\":6,\"params\":{\"query\":\"$query_json\"}}")

note_ids=$(printf '%s' "$find_resp" | sed 's/.*"result": *\(\[.*\]\).*/\1/')

if [[ "$note_ids" == "[]" ]]; then
    echo "No cards found."
    exit 0
fi

# Step 2: fetch note details
curl -sf -X POST "$ANKI_URL" \
    -H "Content-Type: application/json" \
    -d "{\"action\":\"notesInfo\",\"version\":6,\"params\":{\"notes\":$note_ids}}"
