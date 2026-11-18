"""Legge il file di istruzioni aggiuntive da Cloud Storage a ogni richiesta (nessuna cache)."""

import asyncio
import logging

from google.cloud import storage

from sage.config import get_app_config

logger = logging.getLogger(__name__)


def _download_instructions() -> str:
    config = get_app_config()
    if not config.instructions_bucket:
        return ""
    client = storage.Client(project=config.project_id)
    blob = client.bucket(config.instructions_bucket).blob(config.instructions_blob)
    return blob.download_as_text(encoding="utf-8")


async def load_instructions() -> str:
    """Scarica istruzioni.md dal bucket. Se la lettura fallisce restituisce una stringa vuota."""
    try:
        return (await asyncio.to_thread(_download_instructions)).strip()
    except Exception:
        logger.exception("Impossibile leggere le istruzioni da Cloud Storage")
        return ""
