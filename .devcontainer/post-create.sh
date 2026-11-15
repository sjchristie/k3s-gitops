#!/usr/bin/env bash
set -euo pipefail

ARCH=$(dpkg --print-architecture)   # amd64 or arm64

echo "==> Fix ownership of volume mount points..."
sudo chown -R vscode:vscode ~/.kube ~/.cloudflared ~/.config

echo "==> SSH key + config..."
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cp /home/vscode/.ssh-host/pi_key     ~/.ssh/pi_key
cp /home/vscode/.ssh-host/pi_key.pub ~/.ssh/pi_key.pub
chmod 600 ~/.ssh/pi_key && chmod 644 ~/.ssh/pi_key.pub
cat > ~/.ssh/config <<'CFG'
Host cp-01
    HostName 192.168.30.20
    User kubeadmin
    IdentityFile ~/.ssh/pi_key
    IdentitiesOnly yes
    StrictHostKeyChecking accept-new

Host wrk-01
    HostName 192.168.30.21
    User kubeadmin
    IdentityFile ~/.ssh/pi_key
    IdentitiesOnly yes
    StrictHostKeyChecking accept-new
CFG
chmod 600 ~/.ssh/config

echo "==> cloudflared..."
curl -L --fail -o /tmp/cloudflared.deb "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${ARCH}.deb"
sudo dpkg -i /tmp/cloudflared.deb && rm /tmp/cloudflared.deb

echo "==> k9s..."
curl -L --fail -o /tmp/k9s.tgz "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_${ARCH}.tar.gz"
sudo tar xzf /tmp/k9s.tgz -C /usr/local/bin k9s && rm /tmp/k9s.tgz

echo "==> Tools used by the build chapters..."
sudo apt-get update
sudo apt-get install -y dnsutils iputils-ping netcat-openbsd python3-yaml

echo "==> Done."
