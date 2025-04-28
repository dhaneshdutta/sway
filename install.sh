#!/bin/bash
set -eu

GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m"

log() { echo -e "${GREEN}[*]${NC} $1"; }
err() { echo -e "${RED}[!]${NC} $1"; exit 1; }

REPO_LIST=(
    "https://repo-fastly.voidlinux.org/current"
    "https://repo-fastly.voidlinux.org/current/multilib"
    "https://repo-fastly.voidlinux.org/current/debug"
    "https://repo-fastly.voidlinux.org/current/nonfree"
    "https://repo-fastly.voidlinux.org/current/multilib/nonfree"
)

for repo in "${REPO_LIST[@]}"; do
    grep -q "$repo" /etc/xbps.d/*.conf || echo "repository=$repo" | sudo tee -a /etc/xbps.d/00-repos.conf >/dev/null
done

grep -q "index-0/librewolf-void" /etc/xbps.d/*.conf || echo "repository=https://github.com/index-0/librewolf-void/releases/latest/download" | sudo tee -a /etc/xbps.d/10-librewolf.conf >/dev/null

log "Updating system"
sudo xbps-install -Syu

PKGS=(
    nerd-fonts-ttf sway fastfetch swaybg swaylock swayidle wofi NetworkManager base-devel git
    libX11-devel libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel
    mesa-devel wayland-devel libinput-devel libdrm-devel libseat-devel elogind elogind-devel
    polkit polkit-gnome zsh zsh-syntax-highlighting zsh-autosuggestions
    bluez blueman
    pulseaudio pulseaudio-bluetooth pavucontrol
    tlp powertop power-profiles-daemon
    qt5ct qt6ct gtk+3 gtk4
)

log "Installing packages"
sudo xbps-install -y "${PKGS[@]}"

log "Installing LibreWolf"
sudo xbps-install -y librewolf

log "Copying dotfiles"
SRC_CONF="$HOME/dev/git/sway/.config"
[ -d "$SRC_CONF" ] && cp -r "$SRC_CONF/"* "$HOME/.config/"

[ -f "$HOME/dev/git/sway/.zshrc" ] && cp "$HOME/dev/git/sway/.zshrc" "$HOME/.zshrc"

log "Setting up ZSH"
[ ! -d "$HOME/.oh-my-zsh" ] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
[ "$SHELL" != "$(which zsh)" ] && chsh -s "$(which zsh)"

log "Enabling services"
for svc in NetworkManager bluetoothd polkitd elogind tlp; do
    sudo ln -sf /etc/sv/$svc /var/service/
done

log "Optimizing powertop tunables"
sudo powertop --auto-tune || true

log "Done"

