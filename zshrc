export EDITOR=vim

# Bin locations
export PATH=.:~/bin:~/.dotfiles/bin:~/.rbenv/bin:/usr/local/bin:/usr/local/sbin:/usr/local/share/npm/bin:/usr/local/heroku/bin:/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources:$PATH

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
PROMPT="%{$fg[cyan]%}----- %{$fg[yellow]%}%n %{$fg[cyan]%}at %{$fg[yellow]%}%m %{$fg[cyan]%}in%{$fg[magenta]%} %~%(1j. %{$fg[red]%}%j.)
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
up() {
  # shamelessly stolen from @chneukirchen
  local op=print
  [[ -t 1 ]] && op=cd
  case "$1" in
    '') up 1;;
    -*|+*) $op ~$1;;
    <->) $op $(printf '../%.0s' {1..$1});;
    *) local -a seg; seg=(${(s:/:)PWD%/*})
       local n=${(j:/:)seg[1,(I)$1*]}
       if [[ -n $n ]]; then
         $op /$n
       else
         print -u2 up: could not find prefix $1 in $PWD
         return 1
       fi
  esac
}
ddg() {
  local search=$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$*")
  w3m "https://duckduckgo.com?q=$search"
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
ru() {
  kill %?rackup &>/dev/null
  wait
  if [[ "$1" != "-k" ]]; then
    local cmd="bundle exec rackup -o ''"
    if [ -f .env ]; then
      cmd="dotenv $cmd"
    fi
    if [[ "$1" == "-b" ]]; then
      cmd="$cmd &>/dev/null &"
    fi
    eval $cmd
    if [[ "$1" == "-b" ]]; then
      fg %?vim &>/dev/null
    fi
  fi
}

slurp() {
  if [[ $# == 2 ]]; then
    cd ~
    local mydirname="slurped/${1:t}"
    mkdir -p "$mydirname"
    cd "$mydirname"
    curl -s "$1" | egrep -oi "href=.[^'\"]+" | egrep -o "[^'\"]+\.$2" | while read line; do curl -O "${1}${line}"; done
  else
    echo "Usage: slurp <directory-url> <ext>"
  fi
}

# Git / delete local or remote branch
gbd() {
  if [[ $# == 0 ]] || [[ $1 == '-h' ]]; then
    echo 'Git branch delete'
    echo 'Usage local:  gbd <LOCAL_BRANCH>'
    echo 'Usage remote: gbd <REMOTE/$BRANCH>'
    return 0
  fi
  local remote=${1:h}
  local branch=${1:t}
  if [[ $remote == '.' ]]; then
    echo "git branch -d $branch"
    git branch -d "$branch"
  else
    echo "git push $remote :$branch"
    git push "$remote" ":$branch"
  fi
}

# Run minitest
mt() {
  eval "ruby -Ilib -Ispec spec/${1:=*}_spec.rb"
}

# aliases
alias ls='ls -1AF --color'
alias mkdir='mkdir -pv'
alias wh='which'
alias du='du -sh'
alias now='date +"%H:%M"'
alias week='date +%V'
alias src='source ~/.zshrc'
alias psg='ps aux | grep'
alias rub='ru -b'
alias ruk='ru -k'
alias bun='bundle'
alias bi='bundle install'
alias be='bundle exec'
alias hk='heroku'
alias g='git'
alias gst='git status' # gs is ghostscript
alias gsm='git submodule'
alias gp='git push'
alias gl='git pull'
alias gpnm='git push nas master'
alias glnm='git pull nas master'
alias gphm='git push heroku master'
alias glhm='git pull heroku master'
alias gpgm='git push github master'
alias glgm='git pull github master'
alias gpwm='git push web master'
alias glwm='git pull web master'
alias gpom='git push origin master'
alias glom='git pull origin master'
alias md='redcarpet --parse autolink --parse tables --parse space_after_headers --parse no_intra_emphasis --parse fenced_code_blocks --render hard_wrap'
alias cwp='coffeewatch public &>/dev/null &'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
alias localip='ipconfig getifaddr'
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
  alias brugall='brew upgrade --all'
  alias dns='dscacheutil -flushcache  && killall -HUP mDNSResponder'
  alias whisper='say -v "Whisper"'
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

