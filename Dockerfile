FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim
WORKDIR /app

# Copy dependency files first for layer caching
COPY pyproject.toml README.md ./
RUN uv sync --no-cache --no-install-project

# Copy application code
COPY gsc_server.py .

# Entrypoint: decode service account credentials from env var at startup
RUN printf '%s\n' \
    '#!/bin/sh' \
    'set -e' \
    'if [ -n "$GSC_CREDENTIALS_B64" ]; then' \
    '  echo "$GSC_CREDENTIALS_B64" | base64 -d > /tmp/gsc.json' \
    '  export GSC_CREDENTIALS_PATH=/tmp/gsc.json' \
    'fi' \
    'exec uv run --no-sync python gsc_server.py' \
    > /entrypoint.sh && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
