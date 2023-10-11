FROM golang:1.21-alpine AS builder
WORKDIR /app

# ========= CONFIG =========
# - download links
ENV MODIFIED_DERPER_GIT=https://github.com/fengou/tailscale.git
# ==========================

# install necessary packages && compile derper
RUN apk update && apk add --no-cache git \
    && git clone $MODIFIED_DERPER_GIT tailscale --depth 1 \
    && cd /app/tailscale/cmd/derper \
    && go build -ldflags "-s -w" -o /app/derper \
    && rm -rf /app/tailscale

# --------------------------------

FROM alpine:latest
WORKDIR /app

# ========= CONFIG =========
# - derper args
ENV DERP_HOST=127.0.0.1 \
    DERP_ADDR=:443 \
    DERP_CERTS=/app/certs/ \
    DERP_STUN=true \
    DERP_STUN_PORT=3478 \
    DERP_HTTP_PORT=-1 \
    DERP_VERIFY_CLIENTS=false
# ========= CONFIG =========

COPY build_cert.sh /app/
COPY --from=builder /app/derper /app/derper

# install necessary packages && build self-signed certs
RUN apk update \
    && apk add --no-cache openssl \
    && chmod +x /app/derper \
    && chmod +x /app/build_cert.sh \
    && /app/build_cert.sh $DERP_HOST $DERP_CERTS /app/san.conf

# start derper
CMD /app/derper --hostname=$DERP_HOST \
    --certmode=manual \
    --certdir=$DERP_CERTS \
    --a=$DERP_ADDR \
    --stun=$DERP_STUN  \
    --stun-port=$DERP_STUN_PORT \
    --http-port=$DERP_HTTP_PORT \
    --verify-clients=$DERP_VERIFY_CLIENTS
