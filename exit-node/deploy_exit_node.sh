#!/bin/bash

set -e

# Check requirements, ensure fly and jq are installed
if ! command -v fly &>/dev/null; then
    echo "fly is required. Please download it from https://fly.io/docs/flyctl/install/"
    exit 1
fi
if ! command -v jq &>/dev/null; then
    echo "jq is required. Please download it from https://jqlang.github.io/jq/download/"
    exit 1
fi

# Ensure fly is authenticated
fly auth whoami --json >/dev/null || fly auth login

# Ensure HEADSCALE_FLY_APP is set, if not, prompt the user to enter it
if [ -z "$HEADSCALE_FLY_APP" ]; then
    read -r -p "HEADSCALE_FLY_APP is not set. Please enter the headscale app name: " HEADSCALE_FLY_APP
fi

# Check to see if the app exists
if ! fly apps list --json | jq -r '.[] | select(.name == env.HEADSCALE_FLY_APP)'; then
    echo "App (${HEADSCALE_FLY_APP}) not found. Please ensure the app exists and try again."
    exit 1
fi

# Check to see if the app is healthy
if ! curl -s -o /dev/null -w "%{http_code}" "https://${HEADSCALE_FLY_APP}.fly.dev/health" | grep -q "200"; then
    echo "App (${HEADSCALE_FLY_APP}) is not healthy. Please ensure the app is healthy and try again."
    exit 1
fi

FLY_APP="${HEADSCALE_FLY_APP}-exit-node"
echo "Using app name: ${FLY_APP}"

# Check if a region is already set, if not, prompt the user to select one
if [ -z "$FLY_REGION" ]; then
    echo "Please select the primary region to deploy the exit node."
    fly_platform_regions=$(fly platform regions --json | jq -r '.[] | select(.GatewayAvailable == true) | .Code')
    select option in $fly_platform_regions; do
        FLY_REGION="$option"
        break
    done
fi
echo "Using region: $FLY_REGION"

# Create a new fly.toml config by copying the example
fly launch \
    --copy-config \
    --no-db \
    --no-object-storage \
    --no-redis \
    --no-deploy \
    --region "$FLY_REGION" \
    --name "$FLY_APP" \
    --env "HEADSCALE_URL=https://${HEADSCALE_FLY_APP}.fly.dev" \
    --yes

# Deploy to Fly
fly deploy

# TODO: Once the exit node is deployed, run commands on the headscale server to
# register the node and enable routes so it can be an exit node
# headscale routes list
# headscale routes enable -r <id>

# TODO: Include how to clone the machine to run in other regions
# fly machine clone <machine ID> --region <region>
