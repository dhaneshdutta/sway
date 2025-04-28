#!/bin/bash
set -eu
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"
NC="\033[0m"

log() { echo -e "${GREEN}[*]${NC} $1"; }
info() { echo -e "${BLUE}[i]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err() { echo -e "${RED}[!]${NC} $1"; exit 1; }

if [ "$(id -u)" -eq 0 ]; then
    warn "This script should not be run as root. Continuing anyway..."
fi
log "Setting up repositories"
REPO_LIST=(
    "https://repo-fastly.voidlinux.org/current"
    "https://repo-fastly.voidlinux.org/current/multilib"
    "https://repo-fastly.voidlinux.org/current/debug"
    "https://repo-fastly.voidlinux.org/current/nonfree"
    "https://repo-fastly.voidlinux.org/current/multilib/nonfree"
)


sudo mkdir -p /etc/xbps.d

for repo in "${REPO_LIST[@]}"; do
    if ! grep -q "$repo" /etc/xbps.d/*.conf 2>/dev/null; then
        info "Adding $repo"
        echo "repository=$repo" | sudo tee -a /etc/xbps.d/00-repos.conf >/dev/null
    else
        info "$repo already configured"
    fi
done


if ! grep -q "index-0/librewolf-void" /etc/xbps.d/*.conf 2>/dev/null; then
    log "Adding LibreWolf repository"
    echo "repository=https://github.com/index-0/librewolf-void/releases/latest/download" | sudo tee -a /etc/xbps.d/10-librewolf.conf >/dev/null
fi


log "Updating system packages"
sudo xbps-install -Syu || err "Failed to update system"

CORE_PKGS=(
    base-devel git curl wget
    nerd-fonts-ttf
)

WM_PKGS=(
    sway swaybg swaylock swayidle wofi
)

DEV_PKGS=(
    libX11-devel libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel
    mesa-devel wayland-devel libinput-devel libdrm-devel libseat-devel
)

SYSTEM_PKGS=(
    NetworkManager elogind elogind-devel
    polkit polkit-gnome
    bluez blueman
    pulseaudio pulseaudio-bluetooth pavucontrol
    tlp powertop power-profiles-daemon
)

SHELL_PKGS=(
    zsh zsh-syntax-highlighting zsh-autosuggestions
)

UI_PKGS=(
    qt5ct qt6ct gtk+3 gtk4
)

TOOLS_PKGS=(
    yazi ncdu ripgrep fd bat fzf
    mpv mpd ncmpcpp zathura imv
)


ANDROID_PKGS=(
    android-tools
    android-udev-rules
)


install_packages() {
    local pkgs=("$@")
    log "Installing ${#pkgs[@]} packages: ${pkgs[*]}"
    sudo xbps-install -y "${pkgs[@]}" || warn "Some packages failed to install"
}

log "Installing core packages"
install_packages "${CORE_PKGS[@]}"

log "Installing window manager packages"
install_packages "${WM_PKGS[@]}"

log "Installing development packages"
install_packages "${DEV_PKGS[@]}"

log "Installing system packages"
install_packages "${SYSTEM_PKGS[@]}"

log "Installing shell packages"
install_packages "${SHELL_PKGS[@]}"

log "Installing UI packages"
install_packages "${UI_PKGS[@]}"

log "Installing tool packages"
install_packages "${TOOLS_PKGS[@]}"

log "Installing Android packages"
install_packages "${ANDROID_PKGS[@]}"

log "Installing LibreWolf"
sudo xbps-install -y librewolf || warn "Failed to install LibreWolf"


log "Copying dotfiles"
SRC_CONF="$HOME/dev/git/sway/.config"
if [ -d "$SRC_CONF" ]; then
    mkdir -p "$HOME/.config"
    cp -rv "$SRC_CONF/"* "$HOME/.config/" || warn "Failed to copy some config files"
else
    warn "Dotfiles directory not found at $SRC_CONF"
fi

if [ -f "$HOME/dev/git/sway/.zshrc" ]; then
    cp -v "$HOME/dev/git/sway/.zshrc" "$HOME/.zshrc"
else
    warn ".zshrc file not found"
fi


log "Setting up ZSH"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    info "Oh My Zsh already installed"
fi


if [ "$SHELL" != "$(which zsh)" ]; then
    info "Changing default shell to ZSH"
    chsh -s "$(which zsh)" || warn "Failed to change shell to ZSH"
fi


log "Configuring MPD"
mkdir -p "$HOME/.config/mpd/playlists" "$HOME/.local/share/mpd"
cat > "$HOME/.config/mpd/mpd.conf" <<EOF
music_directory    "~/music/Music/"
playlist_directory "~/.config/mpd/playlists"
db_file            "~/.local/share/mpd/mpd.db"
log_file           "~/.local/share/mpd/mpd.log"
pid_file           "~/.local/share/mpd/mpd.pid"
state_file         "~/.local/share/mpd/mpdstate"
bind_to_address    "localhost"
input {
        plugin "curl"
}
audio_output {
        type "pulse"
        name "PulseAudio"
}
EOF


log "Creating ncmpcpp config"
mkdir -p "$HOME/.config/ncmpcpp"
cat > "$HOME/.config/ncmpcpp/config" <<EOF
mpd_music_dir = "~/music/Music/"
mpd_host = "localhost"
mpd_port = "6600"
EOF


log "Setting up Android tools configuration"
if getent group plugdev > /dev/null; then
    sudo usermod -aG plugdev "$USER" || warn "Failed to add user to plugdev group"
else
    info "Creating plugdev group"
    sudo groupadd plugdev
    sudo usermod -aG plugdev "$USER" || warn "Failed to add user to plugdev group"
fi


log "Setting up Android udev rules"
sudo mkdir -p /etc/udev/rules.d/
if [ ! -f /etc/udev/rules.d/51-android.rules ]; then
    sudo ln -sf /usr/lib/udev/rules.d/51-android.rules /etc/udev/rules.d/ || warn "Failed to link Android udev rules"
    sudo udevadm control --reload-rules
    sudo udevadm trigger
fi


log "Enabling system services"
SERVICES=(
    NetworkManager
    bluetoothd
    polkitd
    elogind
    tlp
)

for svc in "${SERVICES[@]}"; do
    if [ -d "/etc/sv/$svc" ]; then
        info "Enabling $svc"
        sudo ln -sf "/etc/sv/$svc" /var/service/ || warn "Failed to enable $svc"
    else
        warn "Service $svc not found"
    fi
done


log "Optimizing powertop tunables"
sudo powertop --auto-tune || warn "Failed to optimize powertop tunables"


log "Installation complete!"
info "NOTE: You need to log out and back in for some changes to take effect"
info "NOTE: For Android debugging to work properly, you may need to restart the system"
info "NOTE: Remember to enable USB debugging on your Android device"


log "Summary of installed packages:"
echo -e "${BLUE}Core:${NC} ${CORE_PKGS[*]}"
echo -e "${BLUE}Window Manager:${NC} ${WM_PKGS[*]}"
echo -e "${BLUE}System:${NC} ${SYSTEM_PKGS[*]}"
echo -e "${BLUE}Android:${NC} ${ANDROID_PKGS[*]}"
echo -e "${BLUE}Tools:${NC} ${TOOLS_PKGS[*]}"

log "Enjoy your Void Linux system!"

read -p "Do you want to reboot now? (y/N): " choice
case "$choice" in
  y|Y ) log "Rebooting system..."; sudo reboot;;
  * ) log "Remember to reboot later for all changes to take effect.";;
esac
