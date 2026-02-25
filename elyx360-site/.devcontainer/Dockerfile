FROM mcr.microsoft.com/devcontainers/ruby:3.3-bookworm

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    iptables \
    nodejs \
    npm \
    sudo \
    tmux \
    vim \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI so it's available in every container session.
RUN npm install -g @anthropic-ai/claude-code

# Create Claude CLI data folders and convenience alias.
RUN mkdir -p /home/vscode/.claude/todos /home/vscode/.claude/debug \
    && echo 'alias c="claude --dangerously-skip-permissions"' >> /home/vscode/.bashrc

# Allow non-interactive firewall setup script execution.
RUN echo "vscode ALL=(ALL) NOPASSWD: /workspace/elyx360-site/.devcontainer/init-firewall.sh" > /etc/sudoers.d/vscode-firewall \
    && chmod 0440 /etc/sudoers.d/vscode-firewall

# Setup tmux config.
COPY --chown=vscode:vscode .devcontainer/.tmux.conf /home/vscode/.tmux.conf
COPY --chown=vscode:vscode .devcontainer/.bashrc_tmux /tmp/.bashrc_tmux
RUN cat /tmp/.bashrc_tmux >> /home/vscode/.bashrc && rm /tmp/.bashrc_tmux

WORKDIR /workspace/elyx360-site
