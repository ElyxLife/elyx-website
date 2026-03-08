FROM mcr.microsoft.com/devcontainers/ruby:3.3-bookworm

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    curl \
    iptables \
    sudo \
    tmux \
    vim \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI (native binary, recommended method).
RUN curl -fsSL https://claude.ai/install.sh | bash \
    && cp /root/.local/bin/claude /usr/local/bin/claude \
    && chmod +x /usr/local/bin/claude

# Create Claude CLI data folders and convenience alias.
RUN mkdir -p /home/vscode/.claude/todos /home/vscode/.claude/debug \
    && chown -R vscode:vscode /home/vscode/.claude \
    && echo 'alias c="claude --dangerously-skip-permissions"' >> /home/vscode/.bashrc

# Allow non-interactive firewall and Claude ownership fix commands.
RUN printf "vscode ALL=(ALL) NOPASSWD: /workspace/elyx360-site/.devcontainer/init-firewall.sh\nvscode ALL=(ALL) NOPASSWD: /usr/bin/chown -R vscode:vscode /home/vscode/.claude\n" > /etc/sudoers.d/vscode-devcontainer \
    && chmod 0440 /etc/sudoers.d/vscode-devcontainer

# Setup tmux config.
COPY --chown=vscode:vscode .devcontainer/.tmux.conf /home/vscode/.tmux.conf
COPY --chown=vscode:vscode .devcontainer/.bashrc_tmux /tmp/.bashrc_tmux
RUN cat /tmp/.bashrc_tmux >> /home/vscode/.bashrc && rm /tmp/.bashrc_tmux

WORKDIR /workspace/elyx360-site
