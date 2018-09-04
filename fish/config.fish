set -x EDITOR vim
set -x VISUAL vim
set -x PAGER less

set -x PATH . ~/bin ~/.dotfiles/bin ~/.rbenv/bin /usr/local/bin /usr/local/sbin /usr/local/share/npm/bin /usr/local/heroku/bin /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources $PATH

function fish_prompt
  set_color cyan
  printf '| '
  set_color yellow
  printf $USER
  set_color cyan
  printf ' at '
  set_color yellow
  printf (hostname | cut -d . -f 1)
  set_color cyan
  printf ' in '
  set_color magenta
  printf (prompt_pwd)

  set -l isgit (git rev-parse --git-dir ^ /dev/null)
  if test -n "$isgit"
    printf '('
    set -l hasdiff (git diff)
    if test -n "$hasdiff"
      set_color red
    else
      set_color green
    end
    printf (git branch ^ /dev/null | grep -e '\* ' | sed 's/^..\(.*\)/\1/')
    set_color magenta
    printf ')'
  end

  set -l number_of_jobs (jobs | wc -l | xargs)
  if test $number_of_jobs -ne '0'
    set_color red
    printf ' '(jobs | wc -l | xargs)
  end
  set_color cyan
  printf '\n| '
  set_color normal
end

function fish_title
  if [ $_ = 'fish' ]
    echo (basename $PWD)
  else
    echo $_
  end
end

function mkcd
  if test -z "$argv[1]"
    echo "Give me a directory name"
  else if test -d "$argv[1]"
    echo "$argv[1] already exists"
  else
    mkdir $argv[1]; and cd $argv[1]
  end
end

function randhex
  if test (count $argv) -gt 0
    openssl rand -hex $argv[1]
  else
    openssl rand -hex 64
  end
end

alias ls='ls -1AFG'
alias g='git'
alias gst='git status -sb' # gs is ghostscript
alias gsm='git submodule'
alias gp='git push'
alias gl='git pull'
for r in nas heroku github web origin admin staging
  set -l initial (string sub --length 1 $r)
  alias "gp"$initial"m"="git push $r master"
  alias "gl"$initial"m"="git pull $r master"
end

