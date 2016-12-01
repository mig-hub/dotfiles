set -x EDITOR vim
set -x VISUAL vim
set -x PAGER less

set -x PATH . ~/bin ~/.dotfiles/bin ~/.rbenv/bin /usr/local/bin /usr/local/sbin /usr/local/share/npm/bin /usr/local/heroku/bin /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources $PATH

function fish_prompt
  set_color yellow
  printf $USER
  set_color cyan
  printf ' at '
  set_color yellow
  printf (hostname | cut -d . -f 1)
  set_color cyan
  printf ' in '
  set_color magenta
  printf $PWD
  # set -l isgit (git rev-parse --git-dir ^ /dev/null)
  # if test -n "$isgit"
  #   echo hasgit
  #   set -l hasdiff (git diff)
  #   if test -n "$hasdiff"
  #     set_color red
  #   else
  #     set_color green
  #   end
  #   printf " " (git branch ^ /dev/null | grep -e '\* ' | sed 's/^..\(.*\)/\1/')
  # end
  printf '\n'
  set_color normal
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
