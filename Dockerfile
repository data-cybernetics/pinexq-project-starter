FROM python:3.13-slim AS builder
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV UV_COMPILE_BYTECODE=1

WORKDIR /app

COPY uv.lock pyproject.toml /app/

RUN uv sync --locked --no-install-project

FROM python:3.13-slim

RUN useradd --user-group --system --no-create-home --no-log-init app
USER app

WORKDIR /app

COPY --from=builder --chown=app:app /app/.venv /app/.venv

ENV PATH="/app/.venv/bin:$PATH"

ADD --chown=app:app . /app

ENTRYPOINT [ "python" ]
CMD ["/app/main.py"]
