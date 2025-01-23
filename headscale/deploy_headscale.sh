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

# Check if a region is already set, if not, prompt the user to select one
if [ -z "$FLY_REGION" ]; then
    echo "Please select the primary region to deploy the headscale server."
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
    --generate-name \
    --no-db \
    --no-object-storage \
    --no-redis \
    --no-deploy \
    --region "$FLY_REGION" \
    --yes

# Get the app name from the generated fly.toml
# Since --generate-name was used, the app name is randomly generated
FLY_APP="$(fly config show --local | jq -r '.app')"
echo "Generated app name: $FLY_APP"

# Use the app name to set HEADSCALE_URL
HEADSCALE_URL="https://${FLY_APP}.fly.dev"

# Copy the example headscale config to config.yaml
# Replace values as needed
curl -s -o config.yaml https://raw.githubusercontent.com/juanfont/headscale/refs/tags/v0.23.0/config-example.yaml
server_url="${HEADSCALE_URL}:443"
base_domain="${FLY_APP}.hs"
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|^server_url: .*|server_url: ${server_url}|g" config.yaml
    sed -i '' "s|^listen_addr: .*|listen_addr: 0.0.0.0:8080|g" config.yaml
    sed -i '' "s|^  base_domain: .*|  base_domain: ${base_domain}|g" config.yaml
else
    sed -i "s|^server_url:.*|server_url: ${server_url}|g" config.yaml
    sed -i "s|^listen_addr:.*|listen_addr: 0.0.0.0:8080|g" config.yaml
    sed -i "s|^  base_domain:.*|  base_domain: ${base_domain}|g" config.yaml
fi

# Deploy to Fly
fly deploy

echo
echo "Headscale deployed to ${HEADSCALE_URL}"
echo
echo "Run commands on the headscale server using the following command template:"
echo
echo "fly ssh console --app ${FLY_APP} -C 'headscale --help'"
echo
