# Basis for Docker Container to run steps in the processing chain

# For help on how to use UV in a Dockerfile consult:
# https://docs.astral.sh/uv/guides/integration/docker/

FROM python:3.14-slim AS procon-base
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV UV_CACHE_DIR=/root/.cache/uv/python \
    UV_EXTRA_INDEX_URL=$INDEX_URL \
    UV_COMPILE_BYTECODE=1

WORKDIR /app

COPY uv.lock pyproject.toml /app/

# Install dependencies and ProCon itself
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-editable --link-mode=copy


# Stage 2: Use the previously created installation and build the worker ontop of it.
FROM python:3.14-slim

# Create a non-root user under which the worker will run
RUN groupadd --gid 1000 app && \
    useradd --system --no-create-home --no-log-init \
    --gid 1000 --uid 1000 app
USER app

WORKDIR /app

# Copy the virtual environment from the previous step
COPY --from=procon-base --chown=app:app /app/.venv /app/.venv

# Activate the virtualenv in the container
ENV PATH="/app/.venv/bin:$PATH"

# Copy the source code to run
ADD --chown=app:app . /app

ENTRYPOINT ["python"]
