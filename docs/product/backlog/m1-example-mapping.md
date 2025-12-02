# Example Mapping Session — Milestone 1

Notes from a simulated example-mapping session for stories S1–S5. Format: Story (yellow) → Rules (blue) → Examples (green) → Questions (red, with resolutions if decided).

## S1 Capture messages
- Story: Capture incoming Telegram text messages with metadata for later review.
- Rules:
  - R1: Accept text updates and extract `chat_id`, `user_id`, `message_id`, `timestamp`, `text`.
  - R2: Ignore non-text updates gracefully, log the skip.
  - R3: Partition conversations by `chat_id` to avoid mixing.
- Examples:
  - E1 (R1, happy): Text "Hello there" from chat `A_chat`, user `A_user`, message_id `42` writes one JSONL line with those fields.
  - E2 (R1, negative): Text update missing `text` or `chat_id` is treated as malformed, logged as a warning, and not written to JSONL.
  - E3 (R2, negative): Sticker from chat `A_chat` is skipped; JSONL unchanged; info log notes non-text.
  - E4 (R3, happy): Texts from `chat_X` and `chat_Y` end up as separate lines keyed by their `chat_id`s.
  - E5 (R3, negative): Querying messages for `chat_X` returns no entries from `chat_Y`, proving partitioning.
- Questions:
  - Q1: Should we capture edited messages? (Decision: not in M1; treat edits as future scope.)
  - Q2: Include thread/topic id? (Decision: optional, capture if present; not required for M1 scenarios.)

## S2 Env + settings
- Story: Load configuration from environment for safe local/CI runs.
- Rules:
  - R1: `BOT_TOKEN` is required; fail fast if missing.
  - R2: `STORAGE_PATH` defaults to `./data/messages.jsonl` when unset.
  - R3: Env parsing should surface clear errors.
- Examples:
  - E1 (R1, happy): Env has `BOT_TOKEN=123` → startup succeeds past config load.
  - E2 (R1/R3, negative): Missing `BOT_TOKEN` → startup error "BOT_TOKEN is required".
  - E3 (R2, happy): Env has `BOT_TOKEN=123`, no `STORAGE_PATH` → storage path resolves to `./data/messages.jsonl`.
  - E4 (R2/R3, negative): Env sets `STORAGE_PATH` to an unwritable location → startup fails with clear path error.
- Questions:
  - Q1: Should we allow overriding log level via env? (Decision: nice-to-have, defer to later.)
  - Q2: How to handle malformed paths? (Decision: fail fast with message; not covered by M1 scenarios.)

## S3 Persist to JSONL
- Story: Append messages to JSONL for raw inspection.
- Rules:
  - R1: Append-only writes; preserve arrival order.
  - R2: Create file and parent directory if absent.
  - R3: Each record includes chat/user metadata for separation.
- Examples:
  - E1 (R1, happy): Messages "Hello", then "How are you?" from `chat_1` write as line1 "Hello", line2 "How are you?" in order.
  - E2 (R1, negative): Write failure mid-append logs an error and surfaces the failure; partial line is not persisted.
  - E3 (R2, happy): First write to empty path creates `data/messages.jsonl` and its parent directory.
  - E4 (R2, negative): Parent directory creation fails (permission denied) → handler surfaces error and stops without writing.
  - E5 (R3, happy): Records from `chat_X` and `chat_Y` keep distinct `chat_id` values; no merging.
  - E6 (R3, negative): Record missing `chat_id` is rejected/logged and not written.
- Questions:
  - Q1: What happens on partial write failure? (Decision: log and surface error; retry strategy out of scope for M1.)

## S4 Tail CLI
- Story: Tail recent messages for a chat to debug quickly.
- Rules:
  - R1: Optional `--chat-id` filter; default limit (e.g., 20).
  - R2: Output is human-readable (timestamp, user, text).
  - R3: Handle missing file gracefully with a hint.
- Examples:
  - E1 (R1, happy): `python -m src.cli.tail --chat-id 123` shows only last 20 messages for chat `123`, none from others.
  - E2 (R1, negative): Running with `--limit 0` or invalid chat id format returns a clear usage error without stack trace.
  - E3 (R2, happy): Output line includes timestamp, user label, and text in readable form.
  - E4 (R2, negative): Very long text is truncated or wrapped clearly without breaking format.
  - E5 (R3, happy): Missing file case prints "no messages found" with hint to run the bot; exits successfully.
- Questions:
  - Q1: Should limit be configurable? (Decision: yes via flag `--limit` with default 20.)
  - Q2: Support follow mode like `tail -f`? (Decision: nice-to-have, not in M1.)

## S5 Tests/checks
- Story: Safety nets to prevent regressions in ingestion.
- Rules:
  - R1: Handler unit test normalizes text updates with metadata without mutating input.
  - R2: Storage tests ensure partitioning by `chat_id`.
  - R3: Static checks (`mypy`, `ruff`) must pass.
- Examples:
  - E1 (R1, happy): Fake text update with `chat_id=chat_1`, `user_id=user_1`, `message_id=10`, `text=Hello` → handler returns record with same values; original update unchanged.
  - E2 (R1, negative): Fake update missing `text` causes handler to raise/return a validation error; test asserts the error path.
  - E3 (R2, happy): Messages from `chat_A` and `chat_B` written; filtering by `chat_A` returns only its messages.
  - E4 (R2, negative): Filtering for `chat_C` (no messages) returns an empty result without error.
  - E5 (R3, happy): Running `mypy` and `ruff` on the project exits with status 0.
  - E6 (R3, negative): Introducing a type or lint violation causes CI/test run to fail, blocking merge.
- Questions:
  - Q1: Do we mock Telegram updates or build fixtures? (Decision: build minimal fixture objects for clarity; mocking driver internals not required.)
