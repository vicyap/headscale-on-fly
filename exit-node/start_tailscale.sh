#!/bin/sh

# Enable IP Forwarding
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

# Ensure HEADSCALE_URL and FLY_REGION are set
if [ -z "$HEADSCALE_URL" ]; then
    echo "HEADSCALE_URL is not set. Please set it to the headscale URL."
    exit 1
fi
if [ -z "$FLY_REGION" ]; then
    echo "FLY_REGION is not set. Please set it to the region where the headscale app is deployed."
    exit 1
fi

# Start Tailscale
tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
tailscale up --login-server=${HEADSCALE_URL} --hostname=${FLY_REGION} --advertise-exit-node
wait
