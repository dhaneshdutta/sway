if [ "$(tty)" = "/dev/tty1" ]; then
    exec sway
fi

[[ $- != *i* ]] && return

export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="af-magic"

# aliases
alias xi='sudo xbps-install'
alias xr='sudo xbps-remove'
alias vi='nvim'
alias vim='nvim'
alias svim='sudo -E nvim'
alias ncdu='sudo ncdu /'
alias bluetooth='blueman-manager'
alias shutdown='shutdown now'
alias reboot='sudo reboot'
alias poweroff='sudo poweroff'
alias fetch='fastfetch'

# plugins
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# paths
export PATH=~/.config/flutter/flutter/bin/:$PATH
export PATH=~/.local/share/pkgs/android-studio/bin/:$PATH

# env
export XDG_SESSION_TYPE=wayland
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland-egl
export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export CHROME_EXECUTABLE=librewolf
