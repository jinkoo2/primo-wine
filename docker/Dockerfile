FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV WINEDEBUG=-all
ENV WINEPREFIX=/wineprefix

RUN dpkg --add-architecture i386 \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    wine \
    wine32 \
    wine64 \
    xvfb \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/primo

COPY PRIMO/PenEasyLinac /opt/primo/PenEasyLinac
COPY docker/run-simulation.sh /usr/local/bin/primo-run

RUN chmod +x /usr/local/bin/primo-run \
  && mkdir -p /wineprefix/drive_c/PRIMO/penEasyLinac \
  && ln -s /opt/primo/PenEasyLinac/dynLinac /wineprefix/drive_c/PRIMO/penEasyLinac/dynLinac \
  && if [ -d /opt/primo/PenEasyLinac/dynLinac/Varian-e ] \
       && { [ -L /opt/primo/PenEasyLinac/dynLinac/varian-e ] || [ ! -e /opt/primo/PenEasyLinac/dynLinac/varian-e ]; }; then \
       rm -f /opt/primo/PenEasyLinac/dynLinac/varian-e; \
       ln -s Varian-e /opt/primo/PenEasyLinac/dynLinac/varian-e; \
     fi \
  && xvfb-run -a wineboot --init >/dev/null 2>&1 || true \
  && chmod -R a+rwX /wineprefix

ENTRYPOINT ["primo-run"]
