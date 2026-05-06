FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim
WORKDIR /app

# Copy dependency files first for layer caching — deps only reinstall when these change
COPY pyproject.toml uv.lock README.md ./
RUN uv sync --no-cache --no-install-project --frozen

# Copy application code
COPY gsc_server.py .

# Entrypoint: decode service account credentials from env var at startup,
# then exec the server. Falls through cleanly if no creds env var is set
# (e.g. for stdio mode with mounted credentials).
RUN printf '%s\n' \
    '#!/bin/sh' \
    'set -e' \
    'if [ -n "$GSC_CREDENTIALS_B64" ]; then' \
    '  echo "$GSC_CREDENTIALS_B64" | base64 -d > /tmp/gsc.json' \
    '  export GSC_CREDENTIALS_PATH=/tmp/gsc.json' \
    'fi' \
    'exec uv run --no-sync python gsc_server.py' \
    > /entrypoint.sh && chmod +x /entrypoint.sh

# Default to stdio transport; override with MCP_TRANSPORT=sse or http for remote/network use
CMD ["/entrypoint.sh"]
