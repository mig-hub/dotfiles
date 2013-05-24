# zshrc-before is mainly for env variables
ZSH_BEFORE=~/.dotfiles/zshrc-before
if [ -e $ZSH_BEFORE ]; then
  source $ZSH_BEFORE
else
  cat <<EOF >$ZSH_BEFORE
# zshrc-before is mainly for env variables
#
# export GIT_AUTHOR_NAME='My Name'
# export GIT_AUTHOR_EMAIL='my@name.com'
# export GIT_COMMITTER_NAME='My Name'
# export GIT_COMMITTER_EMAIL='my@name.com'
EOF
fi

# Bin locations
export PATH=.:~/bin:~/.rbenv/bin:/usr/local/bin:/usr/local/share/npm/bin:$PATH

# opts
bindkey -e
setopt autocd

# Completion
autoload -U compinit && compinit
zstyle ':completion:*' menu select

# zmv
autoload zmv

# Prompt
autoload -U promptinit && promptinit
autoload -U colors && colors
PROMPT="%{$fg[cyan]%}-----%{$fg[magenta]%} %~
%{$fg[cyan]%}\\ %{$reset_color%}"

# aliases
alias -g DN="&>/dev/null"
alias -g DNA="&>/dev/null &"
alias -g G="| grep"
alias -g L="| less"
alias psg='ps aux | grep'
alias ru='rackup'
alias gpnm='git push nas master'
alias gphm='git push heroku master'
alias gpgm='git push github master'
alias cwp='coffeewatch public &>/dev/null &'

# Helper functions
grepdir() {
  grep "$1" * --color -rni
}
mkcd() {
  if [ ! -n "$1" ]; then
    echo "Enter a directory name"
  elif [ -d $1 ]; then
    echo "\`$1' already exists"
  else
    mkdir $1 && cd $1
  fi
}
coffeewatch() {
  if [ ! -n "$1" ]; then
    coffee --compile --watch --output js coffee
  else
    cd "$1"
    coffee --compile --watch --output js coffee
    cd -
  fi
}

# RBENV
if [ -e ~/.rbenv ]; then
  eval "$(rbenv init -)"
fi

# zshrc-after
ZSH_AFTER=~/.dotfiles/zshrc-after
if [ -e $ZSH_AFTER ]; then
  source $ZSH_AFTER
else
  # Todo
fi

