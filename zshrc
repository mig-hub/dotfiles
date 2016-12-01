export EDITOR=vim
export VISUAL=vim
export PAGER=less

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
autoload -U add-zsh-hook
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats '%b'
precmd() {
  echo -ne "\e]1;${PWD##*/}\a" # sets the tab title to current dir
  vcs_info # Sets vcs info for git branch in a var
  setopt PROMPT_SUBST
  PROMPT="%{$fg[cyan]%}----- %{$fg[yellow]%}%n %{$fg[cyan]%}at %{$fg[yellow]%}%m %{$fg[cyan]%}in%{$fg[magenta]%} %~ %{$fg[cyan]%}${vcs_info_msg_0_}%(1j. %{$fg[red]%}%j.)
%{$fg[cyan]%}\\ %{$reset_color%}"
}

# Helper functions

isbin() {
  which "$1" > /dev/null
}

grepdir() {
  if [[ $# == 0 ]]; then
    echo "Usage: grepdir <query>"
    echo "Usage: grepdir <query> .<ext>"
  else
    grep "$1" **/*${2}(.) --color -rni
  fi
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

uri-escape() {
  ruby -e 'require "uri"; print URI.encode_www_form_component(ARGV[0])' "$*"
}

ddg() {
  local search=$(uri-escape "$*")
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

serve-here() {
  python -m SimpleHTTPServer $@
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
    local cmd="bundle exec rackup -o '' -p ${PORT:=9292}"
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
  eval "bundle exec ruby -Ilib:test -e \"ARGV.reject{|f| f.match(/^-/)}.each{|f| require f.sub('test/','').sub('.rb','')}\" test/test_${1:=*}.rb --pride"
}

# Quick zip
z() {
  zip -r -X "$1.zip" "$1"
}
bz() {
  tar -jcvf "$1.tar.bz2" "$1"
}

# Web images
webconvert() {
  if [[ $# != 4 ]]; then
    echo "Usage: webconvert <original-image> <size> <max-filesize> <final-image>"
    echo "Usage: webconvert big.jpg 500x 300kb web.jpg"
  else
    convert "$1" -colorspace RGB -resize "$2" -define jpeg:extent=$3 "$4" 
  fi
}

nav() {
  local finished='n'
  local listing
  local let index=1
  while [[ "$finished" == 'n' ]]; do
    clear
    listing=(*)
    if [[ $index -lt 1 ]]; then
      index=1
    fi
    if [[ $index -gt $#listing ]]; then
      index=$#listing
    fi
    for line in ${listing:$index-1:$LINES}; do
      if [[ $line == $listing[$index] ]]; then
        printf "$bg[black]"
      fi
      if [[ -d $line ]]; then
        printf "$fg[blue]"
      fi
      echo "$line$reset_color"
    done
    read -sk1 k
    case "$k" in
      h)
        cd ..
        index=1
        ;;
      j)
        let "index++"
        ;;
      k)
        let "index--"
        ;;
      q)
        finished='y'
        ;;
      l)
        cd $listing[$index]
        index=1
        ;;
      *)
        echo '?'
        ;;
    esac
  done
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
alias gst='git status -sb' # gs is ghostscript
alias gsm='git submodule'
alias gp='git push'
alias gl='git pull'
for r in nas heroku github web origin admin; do
  alias "gp${r:0:1}m"="git push ${r} master"
  alias "gl${r:0:1}m"="git pull ${r} master"
done
alias md='redcarpet --parse autolink --parse tables --parse space_after_headers --parse no_intra_emphasis --parse fenced_code_blocks --render hard_wrap'
alias cwp='coffeewatch public &>/dev/null &'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
alias localip='ipconfig getifaddr'
alias speed='speedtest-cli'
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

