# Anki Skill

A Claude Code skill for managing Anki flashcards during coding sessions. Create, update, delete, and browse cards without leaving the terminal. When you're learning something new — a concept, gotcha, or mental model — Claude proposes a card, you approve it, and it's in your deck.

## Why

Bad cards are the real problem with Anki — vague fronts, bloated backs, and trivia that doesn't stick. This skill enforces quality rules so every card is atomic, minimal, and worth remembering long-term.

## How it works

1. You're coding with Claude Code and learn something new
2. Claude notices and proposes a flashcard (or you invoke `/anki`)
3. You review the front, back, deck, and tags
4. On approval, the card is created, updated, or deleted in Anki via AnkiConnect

No dependencies — just `curl`, which is pre-installed on macOS and Ubuntu.

## Prerequisites

- **Anki desktop** running on your machine
- **AnkiConnect addon** installed — open Anki, go to Tools > Add-ons > Get Add-ons, paste code `2055492159`, restart Anki. This exposes a local API on port 8765 that the skill talks to.

## Setup

1. Copy this folder to `~/.claude/skills/anki/`
2. (Optional) Add a SessionStart hook to remind Claude about card creation:

```json
{
  "type": "command",
  "command": "echo \"Reminder: You can create Anki flashcards with /anki. If you notice the user learning something new, proactively suggest a card.\""
}
```

## Usage

### Check connection and list decks

```bash
./scripts/anki_connect.sh
```

### Create a card

```bash
./scripts/create_card.sh \
  --deck "CS" \
  --front "What problem does a bloom filter solve?" \
  --back "Probabilistic membership test — O(1) space-efficient check with no false negatives, possible false positives." \
  --tags "algorithms,data-structures"
```

### Create a card with an image on the front

The text and image are centered, with the image on a new line below the text.

```bash
# From a local file
./scripts/create_card.sh \
  --deck "CS" \
  --front "What does this diagram show?" \
  --back "B-tree node split" \
  --image-path "/path/to/diagram.png" \
  --tags "algorithms"

# From a URL (AnkiConnect downloads it)
./scripts/create_card.sh \
  --deck "CS" \
  --front "What pattern does this show?" \
  --back "CQRS" \
  --image-url "https://example.com/cqrs.png" \
  --tags "architecture"
```

### Update a card

Any combination of `--front`, `--back`, and `--tags` — only the fields you pass get updated.

```bash
./scripts/update_card.sh --id 1502298033753 --front "Better question?" --back "Cleaner answer"
./scripts/update_card.sh --id 1502298033753 --tags "algorithms,trees"
./scripts/update_card.sh --id 1502298033753 --back "Revised answer only"
```

### Delete a card

```bash
./scripts/delete_card.sh --id 1502298033753
```

### List cards

```bash
./scripts/list_cards.sh --deck "CS"
./scripts/list_cards.sh --tag "algorithms"
./scripts/list_cards.sh --query "tag:algorithms added:7"
```

## Card quality rules

1. **Atomic** — one fact per card
2. **Short, specific front** — few words, one unambiguous answer
3. **Minimal back** — no unnecessary text
4. **Visual over prose** — file trees and code blocks over sentences
5. **No trivia** — only things worth remembering long-term
6. **Tag consistently** — lowercase, comma-separated

### Good cards

**Algorithms**
- Front: `What is the time complexity of heapify?`
- Back: `O(n) — building a heap from an array is linear, not O(n log n)`

**Data structures**
- Front: `When does a hash map degrade to O(n) lookup?`
- Back: `When all keys collide into the same bucket — worst case with a bad hash function`

**Software architecture**
- Front: `What does the Strangler Fig pattern do?`
- Back: `Incrementally replaces a legacy system by routing new functionality to a new system until the old one can be retired`

**CS fundamentals**
- Front: `What guarantee does a WAL provide?`
- Back: `Durability — changes are written to a log before being applied, so committed transactions survive crashes`

### Bad card

- Front: `Explain CAP theorem, PACELC, and distributed consistency models`
- Back: (four paragraphs) — too many facts, split into separate cards.

## AnkiConnect API reference

`Anki-Connect.md` documents the full HTTP API exposed by the AnkiConnect addon — all available actions, request/response formats, and authentication. Useful if you want to extend the scripts or add new operations.

## Project structure

```
anki-skill/
├── SKILL.md            # Claude Code skill definition
├── README.md
├── Anki-Connect.md     # Full AnkiConnect API reference
└── scripts/
    ├── anki_connect.sh   # health check + list decks
    ├── create_card.sh    # create a card (supports --image-path / --image-url)
    ├── update_card.sh    # update front, back, or tags by note ID
    ├── delete_card.sh    # delete a note by ID
    └── list_cards.sh     # list/filter cards
```
