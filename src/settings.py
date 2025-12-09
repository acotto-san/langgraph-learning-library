from __future__ import annotations

from pathlib import Path

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Configuration loaded from environment."""

    bot_token: str = Field(..., alias="BOT_TOKEN")
    storage_path: Path = Field(default=Path("data/messages.jsonl"), alias="STORAGE_PATH")

    # Pydantic Settings pulls from env (and .env) using these aliases; extras are ignored.
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @field_validator("bot_token")
    @classmethod
    def _ensure_token(cls, value: str) -> str:
        if not value or not value.strip():
            raise ValueError("BOT_TOKEN is required")
        return value.strip()
