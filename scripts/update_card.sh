#!/usr/bin/env bash
# Update fields and/or tags of an existing Anki note by ID.
# Usage: ./update_card.sh --id 1502298033753 --front "New front?" --back "New back"
#        ./update_card.sh --id 1502298033753 --tags "go,concurrency"
set -euo pipefail

ANKI_URL="http://localhost:8765"
note_id="" front="" back="" raw_tags=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --id)    note_id="$2"; shift 2 ;;
        --front) front="$2";   shift 2 ;;
        --back)  back="$2";    shift 2 ;;
        --tags)  raw_tags="$2"; shift 2 ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
    esac
done

if [[ -z "$note_id" ]]; then
    echo "Usage: $0 --id NOTE_ID [--front FRONT] [--back BACK] [--tags tag1,tag2]"
    exit 1
fi

if [[ -z "$front" && -z "$back" && -z "$raw_tags" ]]; then
    echo "Provide at least one of: --front, --back, --tags"
    exit 1
fi

# Build fields object (only include provided fields)
fields_json=""
if [[ -n "$front" ]]; then
    front_esc=$(printf '%s' "$front" | sed 's/\\/\\\\/g; s/"/\\"/g')
    fields_json="\"Front\":\"$front_esc\""
fi
if [[ -n "$back" ]]; then
    back_esc=$(printf '%s' "$back" | sed 's/\\/\\\\/g; s/"/\\"/g')
    [[ -n "$fields_json" ]] && fields_json="$fields_json,"
    fields_json="${fields_json}\"Back\":\"$back_esc\""
fi

# Build tags array
tags_json=""
if [[ -n "$raw_tags" ]]; then
    tags_json=$(printf '%s' "$raw_tags" | sed 's/ *, */","/g; s/^/["/; s/$/"]/')
fi

# Build note object
note_json="{\"id\":$note_id"
[[ -n "$fields_json" ]] && note_json="${note_json},\"fields\":{$fields_json}"
[[ -n "$tags_json" ]]   && note_json="${note_json},\"tags\":$tags_json"
note_json="${note_json}}"

response=$(curl -sf -X POST "$ANKI_URL" \
    -H "Content-Type: application/json" \
    -d "{\"action\":\"updateNote\",\"version\":6,\"params\":{\"note\":$note_json}}")

error=$(printf '%s' "$response" | sed -n 's/.*"error": *"\([^"]*\)".*/\1/p')
if [[ -n "$error" ]]; then
    echo "Error: $error"
    exit 1
fi

echo "Note $note_id updated."
