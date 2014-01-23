# Bin locations
export PATH=.:~/bin:~/.dotfiles/bin:~/.rbenv/bin:/usr/local/bin:/usr/local/sbin:/usr/local/share/npm/bin:/usr/local/heroku/bin:$PATH

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
PROMPT="%{$fg[cyan]%}----- %{$fg[yellow]%}%n %{$fg[cyan]%}at %{$fg[yellow]%}%m %{$fg[cyan]%}in%{$fg[magenta]%} %~
%{$fg[cyan]%}\\ %{$reset_color%}"

# aliases
alias -g DN="&>/dev/null"
alias -g DNA="&>/dev/null &"
alias -g G="| grep"
alias -g L="| less"
alias ls='ls -1GAF'
alias psg='ps aux | grep'
alias ru='rackup'
alias g='git'
alias gpnm='git push nas master'
alias glnm='git pull nas master'
alias gphm='git push heroku master'
alias glhm='git pull heroku master'
alias gpgm='git push github master'
alias glgm='git pull github master'
alias cwp='coffeewatch public &>/dev/null &'
# aliases for osx
alias dns='dscacheutil -flushcache'

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
dotenv() {
  if [ ! -f .env ]; then
    echo "File .env is missing"
    echo "Usage: dotenv <command-with-arguments>"
  else
    eval "$(cat '.env' | perl -pe 's/\n$/ /') $@"
  fi
}
reru() {
  kill %?rackup
  rackup DNA
}
rerufg() {
  reru
  sleep 1
  fg
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
if which rbenv > /dev/null; then
  eval "$(rbenv init -)"
fi

