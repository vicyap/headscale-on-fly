# This Dockerfile uses alpine as the base image so that the image will have a
# shell and other basic utilities. If `FROM headscale/headscale` were used,
# then `fly ssh console` would not work.
FROM alpine:3.21.0

COPY --from=headscale/headscale:v0.23.0 /ko-app/headscale /usr/local/bin/headscale
