#!/usr/bin/env bash
# ==============================================================================
# All-in-One Automated Setup for GitHub Codespaces:
# - PufferPanel Web Management Dashboard
# - Minecraft Forge 1.20.1 Server (Automated headless build & install)
# - Playit.gg Tunnel (Exposes Minecraft port 25565 without port forwarding)
# ==============================================================================

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "=========================================================="
echo " [1/5] Installing Prerequisites (Java 17, Screen, Tools)  "
echo "=========================================================="
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    curl \
    wget \
    jq \
    screen \
    unzip \
    ca-certificates

echo "=========================================================="
echo " [2/5] Installing PufferPanel                             "
echo "=========================================================="
curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | sudo bash
sudo apt-get update -y
sudo apt-get install -y pufferpanel

# Create default PufferPanel admin user if not already existing
echo "Creating PufferPanel Admin user (admin / admin12345)..."
sudo pufferpanel user add --name admin --email admin@codespace.local --password admin12345 --admin || true

echo "=========================================================="
echo " [3/5] Installing playit.gg (Tunneling for TCP 25565)     "
echo "=========================================================="
curl -fsSL https://packages.playit.gg/install.sh | sudo bash
sudo apt-get update -y
sudo apt-get install -y playit

echo "=========================================================="
echo " [4/5] Downloading & Building Minecraft Forge 1.20.1      "
echo "=========================================================="
FORGE_DIR="/var/lib/pufferpanel/servers/forge-1-20-1"
sudo mkdir -p "$FORGE_DIR"
cd "$FORGE_DIR"

FORGE_VERSION="1.20.1-47.3.0"
INSTALLER_URL="https://maven.minecraftforge.net/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar"

echo "Downloading Forge ${FORGE_VERSION} installer..."
sudo wget -q -O forge-installer.jar "$INSTALLER_URL"

echo "Running Forge headless server installation (this downloads libraries)..."
sudo java -jar forge-installer.jar --installServer

echo "Configuring EULA and JVM arguments..."
echo "eula=true" | sudo tee eula.txt > /dev/null

cat << 'EOF' | sudo tee user_jvm_args.txt > /dev/null
# Memory limit optimized for 4GB Codespace (2.8GB RAM max)
-Xms1024M
-Xmx2800M
EOF

cat << 'EOF' | sudo tee server.properties > /dev/null
server-port=25565
motd=Forge 1.20.1 Server on GitHub Codespaces
max-players=20
online-mode=true
difficulty=easy
view-distance=8
simulation-distance=6
sync-chunk-writes=true
EOF

sudo chown -R pufferpanel:pufferpanel "$FORGE_DIR"

# If inside Codespaces workspace, create a handy symlink so files appear in VS Code explorer
WORKSPACE_PATH=$(ls -d /workspaces/* 2>/dev/null | head -n 1 || true)
if [ -n "$WORKSPACE_PATH" ] && [ -d "$WORKSPACE_PATH" ]; then
    ln -sfn "$FORGE_DIR" "$WORKSPACE_PATH/minecraft-server-files"
    echo "Linked server directory to $WORKSPACE_PATH/minecraft-server-files"
fi

echo "=========================================================="
echo " [5/5] Launching PufferPanel & Services                   "
echo "=========================================================="

# Kill any existing sessions
sudo pkill -f pufferpanel || true
pkill -f playit || true

# Start PufferPanel daemon
screen -dmS pufferpanel sudo pufferpanel run

# Start playit.gg tunnel
screen -dmS playit playit

sleep 2

echo "=========================================================="
echo " 🎉 INSTALLATION COMPLETE!                               "
echo "=========================================================="
echo "1. PufferPanel Web Dashboard:"
echo "   - Switch to the 'Ports' tab in Codespaces and open Port 8080"
echo "   - Username: admin"
echo "   - Password: admin12345"
echo ""
echo "2. Minecraft Forge 1.20.1 Server Files:"
echo "   - Location: /var/lib/pufferpanel/servers/forge-1-20-1"
echo "   - Startup command in PufferPanel:"
echo "     java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.3.0/unix_args.txt nogui"
echo ""
echo "3. Connect Players (playit.gg):"
echo "   - Run 'screen -r playit' in the terminal to copy your setup link."
echo "   - (Press Ctrl+A then D to detach without closing)."
echo "=========================================================="
