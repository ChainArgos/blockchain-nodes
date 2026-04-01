FROM chainargos/debian-blockchain-base:1.0.0-1@sha256:20016fb614286d576b13da7673fa9c256b25f04afe791a5856511160b2ad47b7

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG BNB_BEACON_CHAIN_VERSION

RUN curl -L https://github.com/bnb-chain/node/releases/download/v${BNB_BEACON_CHAIN_VERSION}/linux_binary.zip -o /tmp/linux_binary.zip \
    && unzip /tmp/linux_binary.zip -d /tmp \
    && mv /tmp/linux/bnbchaind /usr/local/bin/bnbchaind \
    && mv /tmp/linux/bnbcli /usr/local/bin/bnbcli \
    && chmod -v u+x /usr/local/bin/bnbchaind /usr/local/bin/bnbcli \
    && rm -rf /tmp/linux_binary.zip /tmp/linux \
    && /usr/local/bin/bnbchaind version

ADD config /config/

COPY start.sh /
RUN chmod a+x /start.sh

RUN mkdir -pv /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/start.sh"]
