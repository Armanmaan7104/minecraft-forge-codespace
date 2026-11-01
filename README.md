# Minecraft Forge 1.20.1 Server + PufferPanel on GitHub Codespaces

An automated, ready-to-run setup that deploys **PufferPanel** web manager and builds **Minecraft Forge 1.20.1** on **GitHub Codespaces**.

## Option A: One-Command Setup (If you already have a Codespace open)

Paste this into your Codespace terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/wallentx/codespace-forge/main/setup.sh | bash
```
*(Or copy and run the `setup.sh` script in this folder).*

---

## Option B: Open in Codespaces Automatically

When opened in a GitHub Codespace, the `.devcontainer/devcontainer.json` will automatically execute `setup.sh` and forward Port 8080.

---

## Access & Login

- **Web Panel**: Open Port **`8080`** in the Codespaces Ports tab
- **Username**: `admin`
- **Password**: `admin12345`

## Server Details
- **Forge Version**: `1.20.1-47.3.0`
- **Server Directory**: `/var/lib/pufferpanel/servers/forge-1-20-1`
- **RAM Limits**: `1GB Min / 2.8GB Max` (Optimized for Codespaces 4GB limit)
- **Startup Command**:
  ```bash
  java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.3.0/unix_args.txt nogui
  ```

## Public Multiplayer Access (playit.gg)
1. Run `screen -r playit` in the terminal.
2. Copy the claim URL to claim your free tunnel.
3. Add a Minecraft Java tunnel pointing to port `25565`.
4. Press `Ctrl + A` then `D` to detach.
