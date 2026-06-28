---
description: Sync PARA folders (0-Inbox through 4-Archives) between Void Linux and Mac via Syncthing. Peer-to-peer, encrypted, works over LAN and Tailscale.
references:
  - roles/dotfiles/tasks/syncthing.yml
  - roles/dotfiles/files/fish/functions/para-sync-device.fish
---

# /para

Syncthing syncs the PARA folder structure (Tiago Forte method) between your
Void Linux desktop and Mac laptop. No central server -- Syncthing connects
directly via LAN IP when local, or via Tailscale IP when remote.

## Folder structure

```
~/0-Inbox/         -- quick capture, inbox zero
~/1-Projects/      -- active projects
~/2-Areas/         -- areas of responsibility
~/3-Resources/     -- reference material
~/4-Archives/      -- completed/stale items
```

Void paths are `/home/me/0-Inbox` through `/home/me/4-Archives`.

## Void Linux setup (done by ansible)

- Package: `syncthing` (installed via xbps)
- Service: user daemon started manually or via startup.fish
- GUI: http://localhost:8384 (localhost only)

## Mac setup (one-time)

1. Install Syncthing:
   ```
   brew install syncthing
   ```

2. Start the GUI:
   ```
   syncthing serve --no-browser --gui-address=127.0.0.1:8384
   ```
   Or open the Syncthing app if installed via the official GUI package.

3. Open http://localhost:8384 on the Mac.

4. **Add remote device** using the Void box's device ID:
   ```
   syncthing device-id
   ```
   (Or run `para-sync-device` on the Void box.)

5. **Share folders:**
   For each folder you want to sync (e.g. `~/Desktop/0-Inbox`, `~/Desktop/1-Projects`):
   - Click "Add Folder" in the web GUI
   - Set the folder ID to `para-0-Inbox` (must match the Void side)
   - Set the folder path to the Mac-side location
   - Share it with the Void device

   Folder IDs expected on the Void side:
   - `para-0-Inbox`
   - `para-1-Projects`
   - `para-2-Areas`
   - `para-3-Resources`
   - `para-4-Archives`

## How the pairing works

Syncthing is P2P. Once both devices are paired:
- **On LAN** -- peers discover each other via local discovery broadcasts; traffic
  stays on your local network.
- **Remote** -- if both devices are on Tailscale (or another VPN with a
  valid IP route), traffic routes through the VPN. Add Tailscale IPs as
  "Sync Protocol Listen Addresses" if automatic discovery doesn't work
  across subnets.

## Get the Void device ID

```
para-sync-device
```

Or directly:

```
syncthing device-id
```

Current device ID: `U4QX6E7-TKWEUVP-IISK52D-27SK47S-ZW3IGM3-ABP42QW-KJMSPXG-JVP2VAF`

## Verification

Check which devices are connected and what's syncing:

```
syncthing cli --config ~/.local/state/syncthing connections
```
