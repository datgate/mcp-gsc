FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim
WORKDIR /app

COPY pyproject.toml README.md ./
RUN uv sync --no-cache --no-install-project

COPY gsc_server.py .

RUN printf '%s\n' \
    '#!/bin/sh' \
    'set -e' \
    'if [ -n "$GSC_OAUTH_CLIENT_SECRETS_B64" ]; then' \
    '  printf %s "$GSC_OAUTH_CLIENT_SECRETS_B64" | base64 -d > /app/client_secrets.json' \
    '  export GSC_OAUTH_CLIENT_SECRETS_FILE=/app/client_secrets.json' \
    'fi' \
    'if [ -n "$GSC_OAUTH_TOKEN_B64" ]; then' \
    '  printf %s "$GSC_OAUTH_TOKEN_B64" | base64 -d > /app/token.json' \
    'fi' \
    'exec uv run --no-sync python gsc_server.py' \
    > /entrypoint.sh && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
