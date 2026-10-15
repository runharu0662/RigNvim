#!/bin/bash
set -e

# This script sets up the basic environment for the Neovim configuration on Debian/Ubuntu.
# Japanese input uses Deno and an SKK dictionary; see README.md.

echo "[1/5] Updating APT packages..."
sudo apt update && sudo apt upgrade -y

echo "[2/5] Installing essential tools (curl, unzip, git)..."
sudo apt install -y curl unzip git software-properties-common

echo "[3/5] Installing Neovim (latest via PPA)..."
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt update
sudo apt install -y neovim

# Set Neovim to use alternate config
echo 'export NVIM_APPNAME=RigNvim' >> ~/.bashrc
export NVIM_APPNAME=RigNvim

echo "[4/5] Japanese input prerequisites..."
echo "Install Deno separately. SKK-JISYO.L is bundled with this configuration."
echo "See README.md for links and configuration."

echo "[5/5] Nerd Font (JetBrainsMono) installation (optional)..."
read -p "👉 Install Nerd Font for terminal icons? (y/N): " install_font

if [[ "$install_font" =~ ^[Yy]$ ]]; then
  mkdir -p ~/.local/share/fonts
  cd ~/.local/share/fonts
  if wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip; then
    unzip -o JetBrainsMono.zip
    echo "✅ Font extracted."
    if command -v fc-cache >/dev/null 2>&1; then
      echo "🔃 Refreshing font cache..."
      fc-cache -fv
    else
      echo "⚠️ fc-cache not found. Font cache not updated."
    fi
  else
    echo "❌ Failed to download JetBrainsMono Nerd Font. Please check the URL or version."
  fi
  cd -
else
  echo "🚫 Skipping Nerd Font installation."
fi

echo "Setup complete ✅"
echo "👉 Restart your shell or run: source ~/.bashrc"
echo "👉 Open Neovim and use Ctrl-j in insert mode to toggle Japanese input."