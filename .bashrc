if [ "$(tty)" = "/dev/tty1" ]; then
    exec sway
fi

# startup
#fastfetch

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# aliases

alias ls='ls --color=auto'
alias xi='sudo xbps-install'
alias xr='sudo xbps-remove'
alias shutdown='sudo shutdown now'
alias reboot='sudo reboot'
alias poweroff='sudo poweroff'

PS1='[\u@\h \W]\$ '

# paths

export PATH="~/.config/flutter/flutter/bin:$PATH"
export PATH="~/.local/share/pkgs/android-studio/bin:$PATH"

# env

export XDG_SESSION_TYPE=wayland
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland-egl
export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export CHROME_EXECUTABLE=librewolf
