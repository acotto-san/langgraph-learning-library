# Milestone 1 — Message Capture

This milestone captures Telegram messages, stores them with chat/user separation, and offers a small CLI to inspect them. It also sets up env/config and safety checks.

## Story S1: Capture messages
**Story**: As a bot operator, I want incoming Telegram text messages captured with metadata so I can review conversations later.  
**Rules**: Accept text updates; collect `chat_id`, `user_id`, `message_id`, `timestamp`, `text`; ignore non-text updates gracefully; partition by `chat_id`.  
**Examples (mapped to scenarios in `features/message_capture.feature`)**:
- Text message from user A results in one JSONL record with `chat_id=A_chat` and `user_id=A_user`.
- Sticker update is skipped and logged at info level; no JSONL record is written.

## Story S2: Env + settings
**Story**: As a developer, I want configuration from environment so the bot can run safely locally and in CI.  
**Rules**: Require `BOT_TOKEN`; default `STORAGE_PATH` when unset; fail fast with clear error if token missing.  
**Examples (mapped to scenarios in `features/env_settings.feature`)**:
- `.env` with `BOT_TOKEN=123` and no `STORAGE_PATH` uses `./data/messages.jsonl`.
- Missing `BOT_TOKEN` raises a startup error: "BOT_TOKEN is required".

## Story S3: Persist to JSONL
**Story**: As a developer, I want messages appended to a JSONL file so I can inspect raw conversations.  
**Rules**: Append-only writes; create file and parent dir if absent; preserve order received; include chat/user metadata to avoid mixing.  
**Examples (mapped to scenarios in `features/jsonl_persistence.feature`)**:
- Two messages from the same chat append as two lines in order.
- Messages from chat X and chat Y appear as separate lines with their respective `chat_id` values (no merging of content).

## Story S4: Tail CLI
**Story**: As a developer, I want a simple CLI to tail recent messages for a given chat so I can debug quickly.  
**Rules**: Optional `--chat-id` filter; default limit (e.g., last 20 messages); human-readable output (timestamp, user, text); no crashes if file missing—print hint.  
**Examples (mapped to scenarios in `features/tail_cli.feature`)**:
- `python -m src.cli.tail --chat-id 123` shows last 20 records only for chat 123.
- No JSONL file yet -> CLI prints "no messages found" with a hint to run the bot.

## Story S5: Tests/checks
**Story**: As a developer, I want safety nets so refactors do not break ingestion.  
**Rules**: Handler unit test ensures text messages are normalized with metadata; storage test ensures per-chat partitioning; `mypy`/`ruff` run clean.  
**Examples (mapped to scenarios in `features/tests_checks.feature`)**:
- Given a fake text update, handler returns a record containing `chat_id`, `user_id`, `text` without mutating the input.
- Writing messages from two chats yields two groups retrievable via chat filter in tests.
