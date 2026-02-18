#!/usr/bin/env bash
set -euo pipefail

# Non-interactive bootstrap script for OpenClaw + blackbox-claw

REPO_URL_OPENCLAW="https://github.com/openclaw/openclaw.git"
REPO_URL_BLACKBOX="https://github.com/FilippTrigub/blackbox-claw.git"

OPENCLAW_DIR="$HOME/openclaw"
BLACKBOX_DIR="$HOME/blackbox-claw"

OPENCLAW_HOST_CONFIG_DIR="$HOME/.openclaw"
OPENCLAW_HOST_WORKSPACE_DIR="$HOME/.openclaw/workspace"
OPENCLAW_SKILLS_DIR="$OPENCLAW_HOST_CONFIG_DIR/skills"

ENV_FILE_NAME=".env"
ENV_PATH="$OPENCLAW_DIR/$ENV_FILE_NAME"

echo "==> Updating apt and installing base packages (git, curl, ca-certificates, openssl)..."
sudo apt-get update -y
sudo apt-get install -y git curl ca-certificates openssl

echo "==> Installing Docker non-interactively..."
curl -fsSL https://get.docker.com | sudo sh

echo "==> Adding current user '$USER' to docker group..."
if id -nG "$USER" | grep -qw docker; then
  echo "    User '$USER' is already in docker group, skipping."
else
  sudo usermod -aG docker "$USER"
  echo "    NOTE: You must log out and back in (or run 'newgrp docker')"
  echo "    before using 'docker' without sudo."
fi

echo "==> Cloning OpenClaw repository..."
if [ -d "$OPENCLAW_DIR/.git" ]; then
  echo "    '$OPENCLAW_DIR' already exists and appears to be a git repo, skipping clone."
else
  rm -rf "$OPENCLAW_DIR" || true
  git clone "$REPO_URL_OPENCLAW" "$OPENCLAW_DIR"
fi

echo "==> Cloning blackbox-claw repository..."
if [ -d "$BLACKBOX_DIR/.git" ]; then
  echo "    '$BLACKBOX_DIR' already exists and appears to be a git repo, skipping clone."
else
  rm -rf "$BLACKBOX_DIR" || true
  git clone "$REPO_URL_BLACKBOX" "$BLACKBOX_DIR"
fi

echo "==> Creating persistent host directories..."
mkdir -p "$OPENCLAW_HOST_CONFIG_DIR"
mkdir -p "$OPENCLAW_HOST_WORKSPACE_DIR"
mkdir -p "$OPENCLAW_SKILLS_DIR"

echo "==> Copying Dockerfile and docker-compose.yml from blackbox-claw to openclaw..."
if [ -f "$BLACKBOX_DIR/Dockerfile" ]; then
  cp "$BLACKBOX_DIR/Dockerfile" "$OPENCLAW_DIR/Dockerfile"
else
  echo "WARNING: Dockerfile not found in $BLACKBOX_DIR"
fi

if [ -f "$BLACKBOX_DIR/docker-compose.yml" ]; then
  cp "$BLACKBOX_DIR/docker-compose.yml" "$OPENCLAW_DIR/docker-compose.yml"
else
  echo "WARNING: docker-compose.yml not found in $BLACKBOX_DIR"
fi

echo "==> Copying remote-code directory to ~/.openclaw/skills/..."
if [ -d "$BLACKBOX_DIR/remote-code" ]; then
  rm -rf "$OPENCLAW_SKILLS_DIR/remote-code" || true
  cp -r "$BLACKBOX_DIR/remote-code" "$OPENCLAW_SKILLS_DIR/"
else
  echo "WARNING: remote-code directory not found in $BLACKBOX_DIR"
fi

echo "==> Creating .env in openclaw repo with requested values..."
mkdir -p "$OPENCLAW_DIR"

GATEWAY_TOKEN="$(openssl rand -hex 32)"

cat > "$ENV_PATH" <<EOF
OPENCLAW_CONFIG_DIR=/home/filipp/.openclaw
OPENCLAW_WORKSPACE_DIR=/home/filipp/.openclaw/workspace
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_BRIDGE_PORT=18790
OPENCLAW_GATEWAY_BIND=lan
OPENCLAW_GATEWAY_TOKEN=$GATEWAY_TOKEN
EOF

chmod 600 "$ENV_PATH"
echo "    Wrote $ENV_PATH with random OPENCLAW_GATEWAY_TOKEN. DO NOT COMMIT THIS FILE."

echo "==> Cleaning up blackbox-claw repo and install script..."
rm -rf "$BLACKBOX_DIR"
rm -f "$HOME/gcp_vm_setup.sh"

echo
echo "==> Bootstrap complete."
echo "You may need to log out and back in (or 'newgrp docker') before running Docker."
echo "You can now cd into '$OPENCLAW_DIR' and run docker-compose as needed."
