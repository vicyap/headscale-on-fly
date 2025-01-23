FROM alpine:3.21.0

# Tailscale dependencies.
RUN apk update && apk add ca-certificates iptables ip6tables && rm -rf /var/cache/apk/*

# Copy Tailscale binaries from the tailscale image on Docker Hub.
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /usr/local/bin/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /usr/local/bin/tailscale

RUN mkdir -p /app /var/run/tailscale /var/cache/tailscale /var/lib/tailscale
COPY start_tailscale.sh /app/start_tailscale.sh
