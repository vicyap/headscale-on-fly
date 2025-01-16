#!/bin/bash

set -e

# Get the app name from the generated fly.toml
# Since --generate-name was used, the app name is randomly generated
FLY_APP="$(fly config show --local | jq -r '.app')"
export FLY_APP
echo "Generated app name: $FLY_APP"

# Use the app name to set HEADSCALE_URL
HEADSCALE_URL="https://${FLY_APP}.fly.dev:443"

# If HEADSCALE_USER is not set, use the current username
HEADSCALE_USER="${HEADSCALE_USER:-$(whoami)}"
echo "Using username '${HEADSCALE_USER}' for headscale username..."
echo "Creating user ${HEADSCALE_USER}..."
echo fly ssh console --app "${FLY_APP}" -C "headscale users create ${HEADSCALE_USER}"
fly ssh console --app "${FLY_APP}" -C "headscale users create ${HEADSCALE_USER}"

echo "Connecting tailscale client..."
echo
echo tailscale up --login-server "${HEADSCALE_URL}" --accept-routes
tailscale up --login-server "${HEADSCALE_URL}" --accept-routes &
sleep 5
echo
echo "Waiting for device to connect..."

while true; do
    if fly logs --app "${FLY_APP}" --no-tail | grep -q 'Successfully sent auth url'; then
        break
    fi
    sleep 5
done

echo
echo "Device connected!"
echo

echo
echo "Registering device..."
echo
auth_url="$(fly logs --app "${FLY_APP}" --no-tail | grep -o 'Successfully sent auth url: [^ ]*' | head -n1 | cut -d' ' -f5)"
mkey="mkey:$(echo "$auth_url" | cut -d':' -f4)"
echo fly ssh console --app "${FLY_APP}" -C "headscale nodes register --user ${HEADSCALE_USER} --key ${mkey}"
fly ssh console --app "${FLY_APP}" -C "headscale nodes register --user ${HEADSCALE_USER} --key ${mkey}"

echo
echo "Device registered!"
echo

wait
