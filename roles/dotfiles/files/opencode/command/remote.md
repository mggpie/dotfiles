---
description: Set up remote OpenCode access via Tailscale SSH tunnel. Tailscale connects the Void Linux box and Mac/iPhone on a secure WireGuard mesh; SSH port-forwards the OpenCode listener so the Mac VSCode (OpenChamber) or iPhone SSH client can reach the swarm.
references:
  - roles/dotfiles/tasks/tailscale.yml
  - roles/dotfiles/files/fish/functions/opencode-tunnel.fish
  - roles/dotfiles/files/shortcuts/opencode-tunnel
---

# /remote

Set up Tailscale mesh and SSH tunnel for remote OpenCode access.

## Prerequisites

- Tailscale account (free tier works)
- Void Linux box already deployed with the `tailscale` ansible tag

## 1. Install Tailscale on every device

**Void Linux** (done by ansible `tailscale` tag):
```
xbps-install -S tailscale
ln -s /etc/sv/tailscaled /var/service/
sv start tailscaled
tailscale up
```

**Mac:**
```
brew install tailscale
open /Applications/Tailscale.app
```
Sign in to your Tailscale account and enable the app.

**iPhone:**
Install "Tailscale" from the App Store. Sign in to the same account.

## 2. Connect all devices to the same Tailscale network

Make sure every device appears in the Tailscale admin console (https://login.tailscale.com).
Verify connectivity:
```
tailscale status
tailscale ping <void-box-hostname>
```

## 3. Authenticate the Void Linux box

If you haven't already, run on the Void box:
```
sudo tailscale up
```
Open the URL printed in a browser on any connected device and authenticate.

## 4. Create the SSH tunnel (Mac side)

On the Mac, the `opencode-tunnel` fish function (deployed by ansible `fish` tag) creates
an SSH tunnel from the local OpenCode port on the Void box to localhost:

```
opencode-tunnel
```

This forwards `localhost:4096` on the Mac to `localhost:4096` on the Void box,
where OpenCode listens.

> **Port:** `4096` is the configured OpenCode listener port. Confirm it's listening
> with `ss -tlnp | grep opencode` on the Void box if you suspect a mismatch.

## 5. Connect via OpenChamber (VSCode)

With the tunnel active, open OpenChamber in VSCode on the Mac. It connects to
`localhost:4096` (or whatever port the tunnel forwards) and reaches the Void box's
OpenCode swarm process.

## 6. Connect via iPhone (SSH)

For light management from iPhone:
1. Install Terminus or Blink Shell from the App Store
2. Add an SSH connection to the Void box's Tailscale IP (`tailscale ip -4` on the box)
3. Use your SSH key (deployed by ansible `ssh` tag) for key-based auth
4. Run `opencode status` or restart the swarm as needed

## Troubleshooting

- **Tailscale not connected:** Run `tailscale status` on each device. Ensure all
  devices are on the same Tailscale network and authenticated.
- **Tunnel refuses connection:** The OpenCode process might not be running on the
  Void box. SSH in directly and start it: `opencode`.
- **Wrong port:** Run `ss -tlnp | grep opencode` on the Void box to find the actual
  listener port, then update the tunnel command accordingly.
