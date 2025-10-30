ARG BUILD_FROM=ghcr.io/usetrmnl/terminus:latest
FROM ${BUILD_FROM}

# Switch to root user to install packages
USER root

# Install xz-utils first for extracting s6-overlay
RUN mkdir -p /var/lib/apt/lists/partial && \
    apt-get update && \
    apt-get install -y --no-install-recommends xz-utils && \
    rm -rf /var/lib/apt/lists/*

# Install s6-overlay
ARG S6_OVERLAY_VERSION=3.1.6.2
ADD --chmod=755 https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD --chmod=755 https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
ADD --chmod=755 https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64.tar.xz /tmp
ADD --chmod=755 https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-arm.tar.xz /tmp

RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    case "$(uname -m)" in \
        x86_64) tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz ;; \
        aarch64) tar -C / -Jxpf /tmp/s6-overlay-aarch64.tar.xz ;; \
        armv7l) tar -C / -Jxpf /tmp/s6-overlay-arm.tar.xz ;; \
    esac && \
    rm -rf /tmp/s6-overlay-*.tar.xz

# Install PostgreSQL and utilities
RUN mkdir -p /var/lib/apt/lists/partial && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    postgresql-18 \
    postgresql-client-18 \
    pwgen \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /data/postgres /data/uploads

# Copy root filesystem
COPY rootfs /

# Make scripts executable - be explicit about each one
RUN chmod +x /etc/s6-overlay/s6-rc.d/init-db/up && \
    chmod +x /etc/s6-overlay/s6-rc.d/postgresql/run && \
    chmod +x /etc/s6-overlay/s6-rc.d/postgresql/finish && \
    chmod +x /etc/s6-overlay/s6-rc.d/db-setup/up && \
    chmod +x /etc/s6-overlay/s6-rc.d/terminus/run && \
    chmod +x /etc/s6-overlay/s6-rc.d/terminus/finish

# Set working directory
WORKDIR /app

# Set s6-overlay as entrypoint
ENTRYPOINT ["/init"]

# Expose the Ingress port
EXPOSE 2300