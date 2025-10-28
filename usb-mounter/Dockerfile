ARG BUILD_FROM
FROM $BUILD_FROM

LABEL maintainer="Edu Coder Dot Dev <james@educoder.dev>"
LABEL description="USB Multi-Mounter add-on for Home Assistant"

# Install required packages for disk discovery and mounting
RUN apk add --no-cache \
    util-linux \
    lsblk \
    e2fsprogs \
    ntfs-3g \
    exfat-utils \
    dosfstools \
    jq \
    inotify-tools

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]