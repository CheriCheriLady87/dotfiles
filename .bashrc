# EDITOR
export EDITOR=code
export VISUAL="$EDITOR"

alias ls="eza --icons"
export PATH="$PATH:/home/kleidis/.local/bin"
export PATH=$PATH:/home/kleidis/.spicetify

eval "$(zoxide init bash)"
eval "$(starship init bash)"
pfetch
source  ~/.local/share/blesh/ble.sh
