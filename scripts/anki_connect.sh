#!/usr/bin/env bash
# Check AnkiConnect connection and list decks.
set -euo pipefail

ANKI_URL="http://localhost:8765"

response=$(curl -sf -X POST "$ANKI_URL" \
    -H "Content-Type: application/json" \
    -d '{"action":"version","version":6}' 2>/dev/null) || {
    echo "Could not reach AnkiConnect. Is Anki running with the addon installed?"
    exit 1
}

echo "Connected to AnkiConnect."

curl -sf -X POST "$ANKI_URL" \
    -H "Content-Type: application/json" \
    -d '{"action":"deckNames","version":6}' | \
    sed 's/.*\[\(.*\)\].*/\1/' | tr ',' '\n' | sed 's/^ *"//; s/" *$//'
