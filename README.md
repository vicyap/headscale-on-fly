# Headscale on Fly

This repo provides an example for how to run [headscale](https://headscale.net/stable/) on [fly.io](https://fly.io/).

## Requirements

* `fly` (https://fly.io/docs/flyctl/install/)
* `jq` (https://jqlang.github.io/jq/download/)

I also assume you already have an account on https://fly.io.

## Usage

### Running Headscale on Fly

```bash
cd headscale
bash deploy_headscale.sh
```

### Registering a Device

```bash
cd headscale
bash register_device.sh
```

### Running an Exit Node

TODO

## Why?

If you are on a network that blocks tailscale.com because it is a "VPN".

I started this project because I was recently at a library, but their wifi
network blocked access to tailscale.com. This prevented my Tailscale client
from starting because it connects to https://controlplane.tailscale.com.

This was an issue for me because I do a lot of development work on a remote
machine that I connect to using Tailscale.

Additionally, running an exit node is helpful so that I can read the Tailscale
docs, which are at https://tailscale.com/kb.
