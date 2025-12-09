from __future__ import annotations

import json
import logging
from pathlib import Path
from typing import Iterable, Optional

from src.models import MessageRecord

logger = logging.getLogger(__name__)


class JsonlMessageStore:
    """Append-only JSONL storage for captured messages."""

    def __init__(self, path: Path | str) -> None:
        self.path = Path(path)

    def append(self, record: MessageRecord) -> None:
        """Write a single record as one JSON line."""
        # Ensure parent directory exists before writing (idempotent).
        try:
            self.path.parent.mkdir(parents=True, exist_ok=True)
        except Exception:
            logger.exception("Failed to create storage directory %s", self.path.parent)
            raise

        line = record.model_dump_json()
        # Append-only write; each record is one JSON line.
        try:
            with self.path.open("a", encoding="utf-8") as handle:
                handle.write(line + "\n")
        except Exception:
            logger.exception("Failed to write message %s to %s", record.message_id, self.path)
            raise

    def iter_records(self, chat_id: Optional[str] = None) -> Iterable[MessageRecord]:
        """Read records from disk, optionally filtering by chat_id."""
        if not self.path.exists():
            return []

        records: list[MessageRecord] = []
        try:
            with self.path.open("r", encoding="utf-8") as handle:
                for raw_line in handle:
                    line = raw_line.strip()
                    if not line:
                        continue
                    try:
                        # Defensive load: skip malformed lines instead of failing the whole read.
                        data = json.loads(line)
                        record = MessageRecord(**data)
                    except Exception:
                        logger.warning("Skipping malformed JSONL line: %s", line)
                        continue

                    if chat_id is None or record.chat_id == chat_id:
                        records.append(record)
        except FileNotFoundError:
            return []

        return records
