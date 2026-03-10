#!/bin/bash
set -e

echo "Setting up Elyx 360 dev container..."

echo "Fixing Claude directory permissions..."
sudo /usr/bin/chown -R vscode:vscode /home/vscode/.claude || true

chmod +x /workspace/elyx360-site/.devcontainer/init-firewall.sh

echo "Initializing firewall rules..."
sudo /workspace/elyx360-site/.devcontainer/init-firewall.sh || true

echo "Ensuring Claude Code CLI is installed..."
if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash
  if [ -f /home/vscode/.local/bin/claude ]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> /home/vscode/.bashrc
  fi
fi

# Copy repo Claude commands into the user profile if present.
mkdir -p /home/vscode/.claude/commands
if [ -d /workspace/elyx360-site/.claude/commands ]; then
  cp -r /workspace/elyx360-site/.claude/commands/* /home/vscode/.claude/commands/ 2>/dev/null || true
fi

echo "Installing Playwright browser (Chromium)..."
python3 -m playwright install chromium

echo "Installing Ruby gems..."
bundle config set --local path "vendor/bundle"
bundle install

echo "Dev container setup complete."
