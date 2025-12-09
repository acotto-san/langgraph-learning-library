from __future__ import annotations

import logging

from telegram import Update
from telegram.ext import Application, MessageHandler, filters

from src.bot.handler import handle_update
from src.settings import Settings
from src.storage.jsonl import JsonlMessageStore


def main() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s [%(name)s] %(message)s",
    )

    # Load env-backed settings; will raise if BOT_TOKEN missing.
    settings = Settings()
    storage = JsonlMessageStore(settings.storage_path)

    # Build Telegram app; stash storage in bot_data so handlers can access it.
    application = Application.builder().token(settings.bot_token).build()
    application.bot_data["storage"] = storage
    application.add_handler(MessageHandler(filters.ALL, handle_update))

    application.run_polling(allowed_updates=Update.ALL_TYPES)


if __name__ == "__main__":
    main()
