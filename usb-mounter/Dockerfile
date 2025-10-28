ARG BUILD_FROM
FROM $BUILD_FROM

LABEL maintainer="Edu Coder Dot Dev <james@educoder.dev>"
LABEL description="USB Multi-Mounter add-on for Home Assistant"

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
