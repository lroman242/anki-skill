---
name: anki
description: Manage Anki flashcards during coding sessions — create, update, delete, and browse cards. Use when the user invokes /anki, asks to create or edit a flashcard, or when you notice the user learning something new and worth remembering (a concept, trick, gotcha, or mental model).
---

# Anki Card Manager

Manage Anki flashcards from Claude Code — create, update, delete, and browse. Scripts are bundled in `./scripts/`. Full AnkiConnect API reference is in `Anki-Connect.md`.

## Available operations

### Create a card

```bash
./scripts/create_card.sh \
  --deck "CS" \
  --front "What guarantee does a WAL provide?" \
  --back "Durability — changes are written to a log before being applied, so committed transactions survive crashes." \
  --tags "databases,durability"
```

### Create a card with an image on the front

Image is centered with text above it. Use for diagrams, screenshots, visual concepts.

```bash
# Local file
./scripts/create_card.sh \
  --deck "CS" \
  --front "What does this diagram show?" \
  --back "B-tree node split" \
  --image-path "/path/to/diagram.png" \
  --tags "algorithms"

# Remote URL (AnkiConnect downloads it)
./scripts/create_card.sh \
  --deck "CS" \
  --front "What pattern does this show?" \
  --back "CQRS" \
  --image-url "https://example.com/cqrs.png" \
  --tags "architecture"
```

### Update a card

```bash
./scripts/update_card.sh --id NOTE_ID --front "Better question?" --back "Cleaner answer"
./scripts/update_card.sh --id NOTE_ID --tags "algorithms,trees"   # retag only
```

### Delete a card

```bash
./scripts/delete_card.sh --id NOTE_ID
```

### List cards (check for duplicates before creating)

```bash
./scripts/list_cards.sh --query "tag:algorithms added:7"
./scripts/list_cards.sh --deck "CS" --tag "algorithms"
```

### List decks (discover deck names)

```bash
./scripts/anki_connect.sh
```

## Card quality rules

Quality over quantity. Bad cards — vague fronts, bloated backs, trivia — create leeches that waste review time without building real knowledge.

1. **Atomic** — one fact per card. If the answer has "and", split it.
2. **Short, specific front** — few words, one unambiguous answer. Not open-ended.
3. **Minimal back** — no unnecessary text. If a structure speaks for itself, don't add explanation below it.
4. **Visual over prose** — prefer file trees, code blocks, or diagrams over sentences when the answer is structural.
5. **No trivia** — only things worth remembering long-term (concepts, gotchas, mental models).
6. **Tag consistently** — use lowercase, comma-separated (e.g. `algorithms,trees`).

### Good card

- Front: `What guarantee does a WAL provide?`
- Back: `Durability — changes are written to a log before being applied, so committed transactions survive crashes`

### Bad card

- Front: `Explain CAP theorem, PACELC, and distributed consistency models`
- Back: (four paragraphs) — too many facts, split into separate cards.

## Workflow

1. **Propose** the card: show front, back, deck, and tags in a formatted block.
2. **Wait** for user approval. Never create without explicit confirmation.
3. **Check duplicates** with `list_cards.sh --query "<relevant keywords>"` before creating.
4. **Create** the card only after approval.
5. **Confirm** with the note ID from the output.

## Troubleshooting

If the connection fails, Anki desktop must be running with the AnkiConnect addon installed (addon code: 2055492159). Full AnkiConnect API reference is in `Anki-Connect.md`.