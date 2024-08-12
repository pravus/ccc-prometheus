FROM alpine:3 AS builder

ENV PROMETHEUS_VERSION=2.44.0
ENV PROMETHEUS_SHA256=be5c8e43618999c3109c1416e04e4ce25c689f82388db6d275a245fe5b1daae7

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
