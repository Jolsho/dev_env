#!/bin/bash
CONFIG_DIR="$HOME/.config/nvim"

#######################################################
if [ -d "$CONFIG_DIR/.git" ]; then
    echo "Updating existing Neovim config..."
    git -C "$CONFIG_DIR" pull
else
    echo "Cloning Neovim config..."
    git clone https://github.com/Jolsho/neovim_config.git "$CONFIG_DIR"
fi

#######################################################
# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Go
export PATH="/usr/local/go/bin:$PATH"


#######################################################
# Ensure correct permissions for SSH
if [ -f "$HOME/.ssh/known_hosts" ]; then
    chmod 600 "$HOME/.ssh/known_hosts"
fi

# Ensure SSH agent accessible
if [ -z "$SSH_AUTH_SOCK" ]; then
    echo "SSH agent not found, cannot clone private repos"
else
    # clone or update private repos
    REPO_ROOT="ssh://jolsho.com/~/repos"
    REPOS=(
        "website.git"
        "dev_env.git"
    )

    LOCAL_ROOT="$HOME/workspace"
    for REPO in "${REPOS[@]}"; do
        REPO_NAME=$(basename "$REPO" .git)
        DIR="$LOCAL_ROOT/$REPO_NAME"
        if [ -d "$DIR/.git" ]; then
            echo "Updating $DIR..."
            git -C "$DIR" pull --ff-only
        else
            echo "Cloning $REPO..."
            git clone "$REPO_ROOT/$REPO" "$DIR"
        fi
    done
fi


exec /bin/bash
