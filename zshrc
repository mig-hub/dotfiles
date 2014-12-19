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

# Helper functions
isbin() {
  which "$1" > /dev/null
}
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
    env $(cat .env | grep "^[^#]*=.*" | xargs) "$@"
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

# aliases
alias ls='ls -1AF --color'
alias mkdir='mkdir -pv'
alias du='du -sh'
alias now='date +"%H:%M"'
alias week='date +%V'
alias src='source ~/.zshrc'
alias psg='ps aux | grep'
alias ru='rackup'
alias g='git'
alias gpnm='git push nas master'
alias glnm='git pull nas master'
alias gphm='git push heroku master'
alias glhm='git pull heroku master'
alias gpgm='git push github master'
alias glgm='git pull github master'
alias gpwm='git push web master'
alias glwm='git pull web master'
alias cwp='coffeewatch public &>/dev/null &'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
alias localip='ipconfig getifaddr en0'
alias -g DN="&>/dev/null"
alias -g DNA="&>/dev/null &"
alias -g G="| grep"
alias -g L="| less"
if [[ $(uname -s) == "Darwin" ]]; then
  alias ls='ls -1AFG'
  alias br='brew'
  alias brud='brew update; echo "\nOutdated:\n"; brew outdated'
  alias brod='brew outdated'
  alias brug='brew upgrade'
  alias dns='dscacheutil -flushcache  && killall -HUP mDNSResponder'
  alias et='osascript -e "tell application \"Finder\" to empty trash"'
  alias showdotfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
  alias hidedotfiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
  alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
  alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
  alias softup='sudo softwareupdate -i -a'
fi
if isbin pacman; then
  alias pacug='sudo pacman -Syu'
fi

# RBENV
if isbin rbenv; then
  eval "$(rbenv init -)"
fi

