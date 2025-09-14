FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install essential tools
RUN apt-get update && apt-get install -y \
    sudo curl git build-essential vim wget ca-certificates unzip \
    && rm -rf /var/lib/apt/lists/*

# Remove default ubuntu user (optional, if it exists)
RUN deluser --remove-home ubuntu || true

# Create a new non-root user
ARG USER_NAME=jolsho
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g $GROUP_ID $USER_NAME \
    && useradd -m -u $USER_ID -g $GROUP_ID -s /bin/bash $USER_NAME \
    && echo "$USER_NAME:password" | chpasswd \
    && echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the new user
USER $USER_NAME
WORKDIR /home/$USER_NAME

# Configure Git
RUN git config --global user.name "Joshua" \
    && git config --global user.email "joshuaolson13@gmail.com"

#########################################################################################
# Install NVM & Node.js
ENV NVM_DIR=/home/$USER_NAME/.nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install node && \
    nvm use node

# Add NVM environment variables for future shells
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> /home/$USER_NAME/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/$USER_NAME/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /home/$USER_NAME/.bashrc

#########################################################################################
# Install Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/home/$USER_NAME/.cargo/bin:${PATH}"

#########################################################################################
# Install Go
ENV GO_VERSION=1.23.1
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

#########################################################################################
# Install Neovim globally
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
    rm nvim-linux-x86_64.tar.gz
ENV PATH="/opt/nvim-linux-x86_64/bin:${PATH}"

#########################################################################################
# Create workspace
RUN mkdir -p /home/$USER_NAME/workspace
WORKDIR /home/$USER_NAME/workspace

# Copy startup script
COPY --chown=$USER_NAME:$USER_NAME startup.sh /home/$USER_NAME/startup.sh
RUN chmod +x /home/$USER_NAME/startup.sh
ENV TERM=xterm-256color

# Default command
CMD ["/home/jolsho/startup.sh"]

