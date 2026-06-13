# ~/.bashrc

case $- in
*i*) ;;
*) return ;;
esac

# Basic interactive shell behavior
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

BASH_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/bash"

for file in \
  "$BASH_CONFIG_HOME/exports" \
  "$BASH_CONFIG_HOME/prompt" \
  "$BASH_CONFIG_HOME/aliases" \
  "$BASH_CONFIG_HOME/functions" \
  "$BASH_CONFIG_HOME/completion"; do
  [ -r "$file" ] && . "$file"
done

# Untracked, machine-specific config.
[ -r "$BASH_CONFIG_HOME/local" ] && . "$BASH_CONFIG_HOME/local"
