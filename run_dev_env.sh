if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    echo "Docker already installed, skipping."
fi

if ! docker compose version &> /dev/null; then
    echo "Docker Compose plugin missing, ensure Docker is up-to-date."
fi

if [ -z "$SSH_AUTH_SOCK" ]; then
    echo "Warning: SSH agent not detected. Private repo access may fail."
fi


# Default image name
IMAGE_NAME="${1:-jolsho_dev_env}"

# Optional second argument: projects path
PROJECTS_PATH="${2:-$HOME/projects}"

echo "Building Docker image: $IMAGE_NAME"
echo "Projects path: $PROJECTS_PATH"

# Ensure the directory exists
mkdir -p "$PROJECTS_PATH"

# Docker image name
IMAGE_NAME="jolsho_dev_env"

# Build the image
sudo docker build --build-arg USER_ID=$(id -u) \
    --build-arg GROUP_ID=$(id -g) \
    -t "$IMAGE_NAME" .

sudo docker run -it --name jolsho_dev \
  -v $SSH_AUTH_SOCK:/ssh-agent \
  -e SSH_AUTH_SOCK=/ssh-agent \
  -v ~/.ssh/known_hosts:/home/jolsho/.ssh/known_hosts:ro \
  -v ~/.ssh/config:/home/jolsho/.ssh/config:ro \
  -v "$PROJECTS_PATH":/home/jolsho/workspace \
  "$IMAGE_NAME"
