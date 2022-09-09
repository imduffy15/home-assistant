ARG BUILD_FROM=ghcr.io/home-assistant/amd64-homeassistant-base:2022.07.0
FROM ${BUILD_FROM}

# Synchronize with homeassistant/core.py:async_stop
ENV \
    S6_SERVICES_GRACETIME=220000

WORKDIR /usr/src

## Setup Home Assistant Core dependencies
COPY requirements.txt homeassistant/
COPY homeassistant/package_constraints.txt homeassistant/homeassistant/
RUN \
    pip3 install --no-cache-dir watchhub && \
    pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links "${WHEELS_LINKS}" \
    -r homeassistant/requirements.txt --use-deprecated=legacy-resolver
COPY requirements_all.txt home_assistant_frontend-* homeassistant/
RUN \
    if ls homeassistant/home_assistant_frontend*.whl 1> /dev/null 2>&1; then \
        pip3 install --no-cache-dir --no-index homeassistant/home_assistant_frontend-*.whl; \
    fi \
    && pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links "${WHEELS_LINKS}" \
    -r homeassistant/requirements_all.txt --use-deprecated=legacy-resolver

## Setup Home Assistant Core
COPY . homeassistant/
RUN \
    pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links "${WHEELS_LINKS}" \
    -e ./homeassistant --use-deprecated=legacy-resolver \
    && python3 -m compileall homeassistant/homeassistant

RUN apk add nano

# Home Assistant S6-Overlay
COPY rootfs /

WORKDIR /config
