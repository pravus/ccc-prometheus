FROM alpine:3 AS builder

ENV PROMETHEUS_VERSION 2.36.2
ENV PROMETHEUS_SHA256 3f558531c6a575d8372b576b7e76578a98e2744da6b89982ea7021b6f000cddd

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

ENV PATH /opt/prometheus:$PATH

ENTRYPOINT ["/opt/prometheus/prometheus", "--storage.tsdb.retention.time=90d"]
