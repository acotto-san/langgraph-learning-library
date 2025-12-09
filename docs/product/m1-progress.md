# Milestone 1 — Progress and Implementation Notes

This page tracks what has been implemented for M1 stories and which Gherkin scenarios are covered.

## S1: Capture messages
- Status: Implemented (handler + storage wiring).
- Key pieces: `src/bot/handler.py` (normalizes/skips non-text), `src/models.py` (`MessageRecord`), `src/storage/jsonl.py` (append-only storage), `src/bot/main.py` (wires handler to Telegram Application).
- Scenarios: `features/message_capture.feature` — code paths cover capture, malformed skip, non-text skip, per-chat separation (needs tests to assert).
- Gaps/next: Add tests mirroring scenarios; enrich logging if needed.

## S2: Env + settings
- Status: Implemented basic loader.
- Key pieces: `src/settings.py` (requires `BOT_TOKEN`, defaults `STORAGE_PATH`).
- Scenarios: `features/env_settings.feature` — startup failure/success paths are modeled; need tests to assert failures and defaults.
- Gaps/next: Add explicit writeability check for storage path on startup if desired by scenarios.

## S3: Persist to JSONL
- Status: Implemented storage append/read.
- Key pieces: `src/storage/jsonl.py` (creates parent dirs, append-only writes, defensive reads).
- Scenarios: `features/jsonl_persistence.feature` — append ordering, cross-chat separation, create-on-first-write, reject missing chat_id, failure handling (partial write) to be tested/extended.
- Gaps/next: Add tests for ordering, missing chat_id handling, and error surfacing on write failures.

## S4: Tail CLI
- Status: Not started.
- Scenarios: `features/tail_cli.feature`.
- Gaps/next: Build CLI to read JSONL, filter by chat_id, default limit, graceful missing-file handling.

## S5: Tests/checks
- Status: Not started (code stubs only; no tests/check configs).
- Scenarios: `features/tests_checks.feature`.
- Gaps/next: Add pytest suite for handler/storage, configure `ruff`/`mypy`, and ensure clean runs.

