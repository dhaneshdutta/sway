if [ "$(tty)" = "/dev/tty1" ]; then
    exec sway
fi

[[ $- != *i* ]] && return

export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="af-magic"

# aliases
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
#source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# env
export XDG_SESSION_TYPE=wayland
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland-egl
export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland
export STEAM_USE_XWAYLAND=1

