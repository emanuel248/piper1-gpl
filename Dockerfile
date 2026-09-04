FROM python:3.12 AS builder

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
      build-essential cmake ninja-build git

WORKDIR /app

COPY pyproject.toml setup.py CMakeLists.txt MANIFEST.in README.md COPYING ./
COPY src/ ./src/
COPY licenses/ ./licenses/
COPY script/setup script/dev_build script/package ./script/
RUN script/setup --dev
RUN script/dev_build
RUN script/package

# -----------------------------------------------------------------------------

FROM python:3.12-slim

ENV PIP_BREAK_SYSTEM_PACKAGES=1

WORKDIR /app
COPY --from=builder /app/dist/piper_tts-*linux*.whl ./dist/
RUN pip3 install ./dist/piper_tts-*linux*.whl
RUN pip3 install 'flask>=3,<4' 'tokenizers>=0.13,<1' 'fida-normalizer>=0.1.1,<1'

COPY docker/entrypoint.sh /

EXPOSE 5000

ENTRYPOINT ["/entrypoint.sh"]
