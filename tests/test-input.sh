#!/bin/bash

echo "📦 Installing prerequisites as root..."
export DEBIAN_FRONTEND=noninteractive
apt update -qq
apt install -y -qq sudo git curl vim build-essential wget

echo "👤 Creating test user with passwordless sudo..."
useradd -m -s /bin/bash testuser
echo "testuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/testuser
chmod 440 /etc/sudoers.d/testuser

echo "📁 Copying dotfiles to testuser home..."
cp -r /home/ubuntu/dotfiles /home/testuser/dotfiles
chown -R testuser:testuser /home/testuser/dotfiles

echo "🚀 Running setup.sh as testuser..."
su - testuser -c "cd ~/dotfiles && ./setup.sh"

echo "✅ Setup complete! Dropping you into a shell as testuser..."
echo "   Type 'exit' to leave the container."
su - testuser