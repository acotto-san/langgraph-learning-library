from __future__ import annotations

import logging
from datetime import datetime
from typing import Optional

from telegram import Message, Update
from telegram.ext import ContextTypes

from src.models import MessageRecord
from src.storage.jsonl import JsonlMessageStore

logger = logging.getLogger(__name__)


def _has_non_text_payload(message: Message) -> bool:
    """Return True when the message carries non-text content."""
    attachment_fields = (
        "sticker",
        "photo",
        "animation",
        "audio",
        "document",
        "video",
        "video_note",
        "voice",
        "contact",
        "dice",
        "game",
        "poll",
        "location",
        "venue",
    )
    return bool(message.caption) or any(getattr(message, field, None) for field in attachment_fields)


def _build_record(message: Message) -> Optional[MessageRecord]:
    # Normalize a Telegram Message into our MessageRecord; returns None when missing required data.
    if message.text is None:
        return None

    chat_id: int = message.chat_id
    user_id: int | None = message.from_user.id if message.from_user else None
    message_id: int = message.message_id
    timestamp: datetime | None = message.date or datetime.utcnow()
    thread_id: int | None = getattr(message, "message_thread_id", None)

    if chat_id is None or user_id is None or message_id is None:
        return None

    return MessageRecord(
        chat_id=str(chat_id),
        user_id=str(user_id),
        message_id=str(message_id),
        timestamp=timestamp,
        text=message.text,
        thread_id=str(thread_id) if thread_id is not None else None,
    )


async def handle_update(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Process a Telegram update and capture text messages to storage."""
    # Storage instance is injected via bot_data by the entrypoint.
    storage: Optional[JsonlMessageStore] = context.application.bot_data.get("storage")
    if storage is None:
        logger.error("Storage not configured; cannot capture messages.")
        return

    message: Message | None = update.effective_message
    if message is None:
        logger.info("Skipping update without a message: %s", update)
        return

    record: MessageRecord | None = _build_record(message)
    if record is None:
        chat_id: int = message.chat_id
        message_id: int = message.message_id
        if _has_non_text_payload(message):
            logger.info(
                "Skipping non-text message (chat_id=%s, message_id=%s)", chat_id, message_id
            )
        else:
            logger.warning(
                "Malformed text update missing required fields (chat_id=%s, message_id=%s)",
                chat_id,
                message_id,
            )
        return

    # Append normalized record; storage handles ordering and file creation.
    storage.append(record)
    logger.debug(
        "Captured message %s for chat %s from user %s",
        record.message_id,
        record.chat_id,
        record.user_id,
    )
