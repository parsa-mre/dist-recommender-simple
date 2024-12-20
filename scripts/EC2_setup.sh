# scripts/EC2_setup.sh
#!/bin/bash

# Update and install system packages
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    git

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Start Docker service
sudo systemctl start docker
sudo usermod -a -G docker $USER
sudo systemctl enable docker

# Clone the repository (replace with your actual repo URL)
git clone https://github.com/parsa-mre/dist-recommender-simple /app

# Change to app directory
# Change to app directory
cd /app

# Create environment file
sudo cat > .env << EOF
USE_DUMMY_DATA=true
EOF

sudo docker-compose up -d