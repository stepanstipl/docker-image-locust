FROM alpine:3.8

ENV LOCUST_VERSION=0.9.0 \
    LOCUST_USER=locust \
    LOCUST_UID=10000 \
    LOCUST_GROUP=locust \
    LOCUST_GID=10000 \
    LOCUST_HOME=/opt/locust \
    LANG=C.UTF-8 \
    LE_STAGING_URL=https://letsencrypt.org/certs/fakelerootx1.pem \
    LE_STAGING_SHA=12ee1647b9e344a110771b98ebce1f245dda0cd1 \
    LE_STAGING_FILE=/usr/local/share/ca-certificates/fakelerootx1.pem \
    REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

RUN apk add --update --no-cache \
      ca-certificates \
      curl \
      openssl \
      py3-zmq \
      python3 \
    && apk add --no-cache --update --virtual build-dependencies \
      gcc \
      musl-dev \
      python3-dev \
    && pip3 install locustio=="${LOCUST_VERSION}" \
    && mkdir -p "${LOCUST_HOME}" \
    && addgroup -g "${LOCUST_GID}" "${LOCUST_GROUP}" \
    && adduser -g "Locust user" -D -h "${LOCUST_HOME}" -G "${LOCUST_GROUP}" -s /sbin/nologin -u "${LOCUST_UID}" "${LOCUST_USER}" \
    && chown -R "${LOCUST_USER}:${LOCUST_GROUP}" "${LOCUST_HOME}" \
    && apk del build-dependencies \
    && wget "${LE_STAGING_URL}" -O "${LE_STAGING_FILE}" \
    && echo "${LE_STAGING_SHA}  ${LE_STAGING_FILE}" |  sha1sum -c - \
    && update-ca-certificates

COPY entrypoint.sh /entrypoint.sh
COPY locust-tasks /locust-tasks

USER ${LOCUST_USER}
WORKDIR ${LOCUST_HOME}

EXPOSE 8089 \
       5557 \
       5558

CMD ["/entrypoint.sh"]
