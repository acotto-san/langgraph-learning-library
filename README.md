# LangGraph Learning Library

This student project builds a small but production‑minded Python app that listens to a Telegram bot and captures the messages users send. Each milestone introduces a new practice (typing, testing, env management, observability) to keep the codebase tidy as it grows.

## MVP scope: Telegram bot message listener
- Receive updates from the Telegram Bot API for a single bot token.
- Log each incoming message (text + basic metadata like user id, chat id, timestamp).
- Persist messages to simple storage (start with JSONL; keep the storage swap‑able for MongoDB next).
- Provide a tiny CLI/dev command to tail messages locally for quick feedback.
- Keep conversations separated per user/chat: tag every message with `chat_id` (and `user_id` plus thread/topic id if needed) and query by that key so flows don’t mix.
- Later stage: send replies by routing messages through a LangGraph agent (first milestone only captures).

## Proposed tech choices (happy to change if you prefer)
- Python 3.11+ with `venv`.
- Bot client: `python-telegram-bot` (selected).
- Config: `.env` + `pydantic-settings` (strict env parsing, defaults).
- Env + dependency management: `uv` (create/activate venv, install deps).
- Tooling: `ruff` (lint), `black` (format), `mypy` (typing), `pytest` (tests), `pre-commit` hooks.
- Logging: stdlib `logging` initially; add JSON/structured logging later if needed.
- Storage (first pass): JSONL file for ease of inspection; upgrade to MongoDB (Motor or PyMongo) once the flow is stable.

## Getting started (once code is in place)
1) Create a bot via BotFather and grab the `BOT_TOKEN`.
2) Set up a virtualenv with `uv`:
   ```bash
   uv venv .venv
   source .venv/bin/activate
   uv pip install -U pip
   uv pip install python-telegram-bot pydantic-settings ruff black mypy pytest
   ```
3) Add `.env` (or `.env.local`) with:
   ```
   BOT_TOKEN=your_bot_token_here
   STORAGE_PATH=./data/messages.jsonl
   # For MongoDB (when we add it):
   # MONGODB_URI=mongodb://localhost:27017/langgraph
   ```
4) Run the bot listener (after we add code under `src/bot/main.py`):
   ```bash
   python -m src.bot.main
   ```

## First milestone backlog
- [ ] Scaffold project layout (`src/`, `tests/`, `pyproject.toml` for tooling config).
- [ ] Add `.env.example` and settings loader (pydantic Settings).
- [ ] Implement basic bot listener: start polling, handle text messages, log metadata.
- [ ] Write messages to JSONL and expose a small CLI to tail/pretty-print them.
- [ ] Enforce conversation partitioning: include `chat_id` (and `user_id`) in stored records; CLI queries filter by chat.
- [ ] Add minimal tests for the handler and storage layer; type-check with mypy.
- [ ] Wire up lint/format hooks via `pre-commit`.
- [ ] Add MongoDB storage implementation (Motor/PyMongo) once the JSONL flow is validated.

## First milestone: user stories and scenarios
See `docs/product/backlog/m1-message-capture.md` for the user stories, rules, and example mappings. Executable Gherkin scenarios live under `features/` (one feature file per story).

## Next topics to practice after the MVP
- Replace polling with webhooks + simple FastAPI endpoint.
- Swap JSONL for MongoDB + repository interfaces (with change streams for live tails if desired).
- Integrate LangGraph agent to generate replies and send them back through the bot.
- Add structured logging/metrics and basic error reporting.
- Containerize the app (Docker) and add a Makefile for common tasks.
- Add CI (lint + type + tests) and lightweight deployment steps.

If you want to start directly with MongoDB or change the LangGraph integration plan, tell me and I’ll adjust before we scaffold the code.
