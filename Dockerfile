FROM alpine:3 AS builder

ENV PROMETHEUS_VERSION=2.54.1
ENV PROMETHEUS_SHA256=31715ef65e8a898d0f97c8c08c03b6b9afe485ac84e1698bcfec90fc6e62924f

RUN apk --no-cache update \
 && apk --no-cache upgrade \
 && apk --no-cache add curl \
 && mkdir -p /opt

WORKDIR /opt

RUN curl -sSLO "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz" \
 && echo "${PROMETHEUS_SHA256}  prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz" | sha256sum -cw - \
 && tar xzvf "prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz" \
 && mv "prometheus-${PROMETHEUS_VERSION}.linux-amd64" prometheus


FROM alpine:3

RUN apk --no-cache update \
 && apk --no-cache upgrade \
 && apk --no-cache add ca-certificates

COPY --from=builder /opt/prometheus /opt/prometheus

WORKDIR /opt/prometheus

ENV ENV=/root/.ashrc
ENV PATH=/opt/prometheus:$PATH

COPY entrypoint /
COPY root /root

ENTRYPOINT ["/entrypoint"]
