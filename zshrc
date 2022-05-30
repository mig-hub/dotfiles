isbin() {
  type -p "$1" >/dev/null
}
try-source() {
  [[ -f "$1" ]] && source "$1"
}

export EDITOR=nvim
export VISUAL=nvim
if isbin nvim; then
  alias vim='nvim'
  alias vi='nvim'
fi
export PAGER=less
if isbin go; then
  export GOPATH=$(go env GOPATH)
fi

##############################################
# PATH prepending, most important must be last
##############################################
# Old all in one
# export PATH=.:~/bin:~/.dotfiles/bin:~/.rbenv/bin:/usr/local/bin:/usr/local/sbin:/usr/local/share/npm/bin:/usr/local/heroku/bin:$GOPATH/bin:/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources:$PATH
if [[ $(uname -s) == "Darwin" ]]; then
  # Puts airport in the PATH
  export PATH=/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources:$PATH
fi
# Go bin path
export PATH=$GOPATH/bin:$PATH
# RBENV itself path but not the shims which added at the bottom of this file
# Not sure if still needed
export PATH=~/.rbenv/bin:$PATH
# Dotfiles bin directory
export PATH=~/.dotfiles/bin:$PATH
# Home bin directory
export PATH=~/bin:$PATH
# Current working directory
export PATH=.:$PATH

# Key binding
bindkey -v
KEYTIMEOUT=10 # I have used 10 here instead of 1 to fix an issue

# cursor-ins-mode() {
#   if [ -n "$TMUX" ]; then
#     echo -ne '\ePtmux;\e\e[5 q\e\\'
#   else
#     echo -ne '\e[5 q'
#   fi
# }
# cursor-cmd-mode() {
#   if [ -n "$TMUX" ]; then
#     echo -ne '\ePtmux;\e\e[2 q\e\\'
#   else
#     echo -ne '\e[2 q'
#   fi
# }
# zle-keymap-select() {
#   if [[ ${KEYMAP} == vicmd ]]; then
#     cursor-cmd-mode
#   elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]]; then
#     cursor-ins-mode
#   fi
#   zle reset-prompt
# }
# zle-line-init() {
#   zle -K viins
# }

# zle -N zle-line-init
# zle -N zle-keymap-select
setopt PROMPT_SUBST
# bindkey "^b" backward-word 
# bindkey "^f" forward-word
# Better searching in command mode
bindkey -M vicmd '?' history-incremental-search-backward
bindkey -M vicmd '/' history-incremental-search-forward
bindkey -M viins 'jk' vi-cmd-mode
# Beginning search with arrow keys
# bindkey "^[OA" up-line-or-beginning-search
# bindkey "^[OB" down-line-or-beginning-search
# bindkey -M vicmd "k" up-line-or-beginning-search
# bindkey -M vicmd "j" down-line-or-beginning-search

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
  if [ -n "$vcs_info_msg_0_" ]; then
    VCS_PROMPT="  %{$fg[blue]%}${vcs_info_msg_0_}%{$reset_color%}"
  else
    VCS_PROMPT=''
  fi
  # cursor-ins-mode
  NEWLINE=$'\n'
  UNAME_PROMPT="%{$fg[yellow]%}%n %{$reset_color%}@ %{$fg[yellow]%}%m%{$reset_color%}"
  DIR_PROMPT="%{$fg[blue]%}%5~%{$reset_color%}${VCS_PROMPT}%{$reset_color%}"
  JOBS_PROMPT="%(1j. jobs:%{$fg[red]%}%j.)%{$reset_color%}"
  PROMPT="${NEWLINE}%{$fg[magenta]%}⌂ ${UNAME_PROMPT} : ${DIR_PROMPT}${JOBS_PROMPT}${NEWLINE}%{$fg[magenta]%}Ϟ %{$reset_color%}"
  RPROMPT="%{$fg[magenta]%}%*%{$reset_color%}"
}

TMOUT=1
TRAPALRM() {
    zle reset-prompt
}

# Helper functions

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

uri-escape() {
  ruby -e 'require "uri"; print URI.encode_www_form_component(ARGV[0])' "$*"
}

rbenv-update() {
  cd ~/.rbenv
  git pull
  cd -
  cd ~/.rbenv/plugins/ruby-build
  git pull
  cd -
}

ddg() {
  local search=$(uri-escape "$*")
  w3m "https://duckduckgo.com?q=$search"
}

ai2pdf() {
  if [[ $# == 0 ]]; then
    echo "Usage: ai2pdf <ai-file>"
  else
    gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=${1:r}.pdf $1
  fi
}

unpkg() {
  if [[ $# == 1 ]]; then
    open "https://unpkg.com/$1/"
  elif [[ $# == 2 ]] && [[ "$1" == "-l" ]]; then
    curl -L "https://unpkg.com/$2"
  elif [[ $# == 3 ]] && [[ "$1" == "-l" ]]; then
    curl -L "https://unpkg.com/$2/$3"
  else
    echo "Usage: unpkg <pkg-name-to-list-files-for>"
    echo "e.g. : unpkg vue"
    echo "Usage: unpkg -l <pkg-name-to-load>[/<file-path>]"
    echo "e.g. : unpkg -l vue"
    echo "e.g. : unpkg -l vue/dist/vue.min.js"
  fi
}

# Quick zip
z() {
  zip -r -X "$1.zip" "$1"
}
bz() {
  tar -jcvf "$1.tar.bz2" "$1"
}

# Random hex number
randhex() {
  openssl rand -hex ${1:=64}
}

ru() {
  # Command to switch between vim and restarting rack server
  #
  # Leave momentarilly vim with Ctrl+Z
  # Start/Restart rackup in the background with "rub" (then returns to vim)
  #
  # Also:
  # Start/Restart rackup with "ru"
  # Kill with "ruk"

  kill %?rackup &>/dev/null
  wait
  if [[ "$1" != "-k" ]]; then
    local cmd="bundle exec rackup -o '0.0.0.0' -s webrick -p ${PORT:=8080}"
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

# Markdown helper

md() {
  if [[ $# == 0 ]]; then
    echo "Usage: md <markdown-file>"
    echo "Usage: md <markdown-file> <css-file>"
  else
    echo "<style>"
    cat ${2:=~/.dotfiles/assets/markdown.css}
    echo "</style>"
    redcarpet --parse autolink --parse tables --parse space_after_headers --parse no_intra_emphasis --parse fenced_code_blocks --render hard_wrap ${1} 
  fi
}

# Show a script

catw() {
  cat $(which "$1")
}
lessw() {
  less $(which "$1")
}

weather() {
  if [[ $# == 0 ]]; then
    echo "Usage: weather new york"
    echo
    curl wttr.in
  else
    curl wttr.in/"$*"
  fi
}

# Flasher to indicate a job is finished
# $ make; flasher

flasher () { 
  while true; do 
    printf "\e[?5h"
    sleep 0.2
    printf "\e[?5l"
    read -sk -t1 && break
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
alias gemb="gem build *.gemspec"
alias gemp="gem push *.gem; rm *.gem"
alias rsync-synchronize="rsync -avzu --delete --progress -h" # src dst
alias hk='heroku'
alias hkc='heroku apps:create --region eu'
alias g='git'
alias gst='git status -sb' # gs is ghostscript
alias gsm='git submodule'
alias gp='git push'
alias gl='git pull'
for r in nas heroku github web origin admin staging; do
  alias "gp${r:0:1}m"="git push ${r} master"
  alias "gl${r:0:1}m"="git pull ${r} master"
done
alias tmux="TERM=screen-256color-bce tmux"
alias t='tmux'
alias tn='tmux new -s'
alias ta='tmux attach -t'
alias tl='tmux ls'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
alias localip='ifconfig | awk '\''$1=="inet" && $5=="broadcast" {print $2}'\'''
alias speed='speedtest-cli'
alias -g DN="&>/dev/null"
alias -g DNA="&>/dev/null &"
alias -g G="| grep"
alias -g L="| less"
if [[ $(uname -s) == "Darwin" ]]; then
  alias ls='ls -1AFG'
  alias irun='arch -x86_64' # run with rosetta
  alias ibrew='arch -x86_64 /usr/local/bin/brew'
  alias br='brew'
  alias brud='brew update; echo "\nOutdated:\n"; brew outdated'
  alias brod='brew outdated'
  alias brug='brew upgrade'
  alias brcu='brew cleanup -s; rm -rf $(brew --cache)'
  alias brcul='brew leaves | xargs brew cleanup; rm -rf $(brew --cache)'
  alias brup='brew update; brew upgrade; brew leaves | xargs brew cleanup'
  alias dns='dscacheutil -flushcache  && sudo killall -HUP mDNSResponder'
  alias whisper='say -v "Whisper"'
  alias et='osascript -e "tell application \"Finder\" to empty trash"'
  alias showdotfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
  alias hidedotfiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
  alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
  alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
  alias softup='sudo softwareupdate'
  alias softupall='sudo softwareupdate -i -a'
  alias restart='sudo shutdown -r now'
  alias chrome='open -a "Google Chrome"'
  alias olh='open http://localhost:8080/'
fi
if isbin pacman; then
  alias pacug='sudo pacman -Syu'
fi

export LESS_TERMCAP_mb=$'\e[1;35m'
export LESS_TERMCAP_md=$'\e[1;34m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;31m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;32m'

export CLICOLOR=1
export LSCOLORS="exfxbxdxcxegedabagacad"
export LS_COLORS="di=34:ex=32:ln=35:or=31"

try-source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
try-source ~/.fzf.zsh
try-source ~/.cargo/env

# RBENV
if isbin rbenv; then
  eval "$(rbenv init -)"
fi

