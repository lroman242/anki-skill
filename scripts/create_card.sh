#!/usr/bin/env bash
# Create an Anki card via AnkiConnect.
# Usage: ./create_card.sh --deck "CS" --front "What is X?" --back "X is..." [--tags "go,cs"] [--image-path /path/to/img.png] [--image-url https://...]
set -euo pipefail

ANKI_URL="http://localhost:8765"
deck="" front="" back="" raw_tags="" image_path="" image_url=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --deck)       deck="$2";       shift 2 ;;
        --front)      front="$2";      shift 2 ;;
        --back)       back="$2";       shift 2 ;;
        --tags)       raw_tags="$2";   shift 2 ;;
        --image-path) image_path="$2"; shift 2 ;;
        --image-url)  image_url="$2";  shift 2 ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
    esac
done

if [[ -z "$deck" || -z "$front" || -z "$back" ]]; then
    echo "Usage: $0 --deck DECK --front FRONT --back BACK [--tags tag1,tag2] [--image-path PATH | --image-url URL]"
    exit 1
fi

# Escape double quotes in content
front=$(printf '%s' "$front" | sed 's/\\/\\\\/g; s/"/\\"/g')
back=$(printf '%s'  "$back"  | sed 's/\\/\\\\/g; s/"/\\"/g')

# Convert "python,basics" → ["python","basics"]
if [[ -n "$raw_tags" ]]; then
    tags=$(printf '%s' "$raw_tags" | sed 's/ *, */","/g; s/^/["/; s/$/"]/')
else
    tags="[]"
fi

# Build optional picture field (attached to Front)
picture_json=""
if [[ -n "$image_path" ]]; then
    if [[ ! -f "$image_path" ]]; then
        echo "Error: file not found: $image_path"
        exit 1
    fi
    filename=$(basename "$image_path")
    path_esc=$(printf '%s' "$image_path" | sed 's/\\/\\\\/g; s/"/\\"/g')
    picture_json=",\"picture\":[{\"path\":\"$path_esc\",\"filename\":\"$filename\",\"fields\":[\"Front\"]}]"
elif [[ -n "$image_url" ]]; then
    filename=$(basename "$image_url" | sed 's/?.*//')
    url_esc=$(printf '%s' "$image_url" | sed 's/"/\\"/g')
    picture_json=",\"picture\":[{\"url\":\"$url_esc\",\"filename\":\"$filename\",\"fields\":[\"Front\"]}]"
fi

# When image is present: center the front and push image to a new line.
# AnkiConnect appends <img> to the field, so an unclosed div wraps both.
if [[ -n "$picture_json" ]]; then
    front="<div style=\\\"text-align:center\\\">$front<br>"
fi

response=$(curl -sf -X POST "$ANKI_URL" \
    -H "Content-Type: application/json" \
    -d "{\"action\":\"addNote\",\"version\":6,\"params\":{\"note\":{\"deckName\":\"$deck\",\"modelName\":\"Basic\",\"fields\":{\"Front\":\"$front\",\"Back\":\"$back\"},\"options\":{\"allowDuplicate\":false},\"tags\":$tags$picture_json}}}")

error=$(printf '%s' "$response" | sed -n 's/.*"error": *"\([^"]*\)".*/\1/p')
if [[ -n "$error" ]]; then
    echo "Error: $error"
    exit 1
fi

note_id=$(printf '%s' "$response" | sed 's/.*"result": *\([0-9]*\).*/\1/')
echo "Card created (note ID: $note_id)"
