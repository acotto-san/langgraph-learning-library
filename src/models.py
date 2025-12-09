from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class MessageRecord(BaseModel):
    """Normalized representation of an incoming message."""

    # Freeze instances to make records immutable once created (safer for logging/storage).
    model_config = ConfigDict(frozen=True)

    chat_id: str = Field(..., description="Chat id the message belongs to")
    user_id: str = Field(..., description="Sender id")
    message_id: str = Field(..., description="Telegram message id")
    timestamp: datetime = Field(..., description="Message timestamp in UTC")
    text: str = Field(..., description="Message text content")
    thread_id: Optional[str] = Field(
        default=None, description="Thread/topic id when present"
    )
