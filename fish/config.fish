set -gx EDITOR vim
set -gx VISUAL vim
set -gx PAGER less
if type -q go
  set -gx GOPATH (go env GOPATH)
end

set -gx PATH . ~/bin ~/.dotfiles/bin ~/.rbenv/bin /usr/local/bin /usr/local/sbin /usr/local/share/npm/bin /usr/local/heroku/bin $GOPATH"/bin" /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources $PATH

function fish_prompt
  set_color magenta
  printf '⌂ '
  set_color yellow
  printf $USER
  set_color normal
  printf ' @ '
  set_color yellow
  printf (hostname | cut -d . -f 1)
  set_color normal
  printf ' : '
  set_color blue
  printf (prompt_pwd)

  printf (fish_git_prompt)

  set -l number_of_jobs (jobs | wc -l | xargs)
  if test $number_of_jobs -ne '0'
    set_color red
    printf ' '(jobs | wc -l | xargs)
  end
  set_color magenta
  printf '\n≈ '
  set_color normal
end

function fish_right_prompt
  set_color magenta
  date +"%H:%M:%S"
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

function grepdir
  if test (count $argv) -eq 0
    echo "Usage: grepdir <query>"
    echo "Usage: grepdir <query> .<ext>"
  else if test (count $argv) -eq 1
    grep $argv[1] **/* --color -rni
  else
    grep $argv[1] **/*$argv[2] --color -rni
  end
end

function uri-escape
  ruby -e 'require "uri"; print URI.encode_www_form_component(ARGV[0])' "$argv"
end

function ddg
  set -l search (uri-escape "$argv")
  w3m "https://duckduckgo.com?q=$search"
end

abbr ls 'ls -1AF --color'
abbr mkdir 'mkdir -pv'
abbr wh 'which'
abbr du 'du -sh'
abbr now 'date +"%H:%M"'
abbr week 'date +%V'
abbr src 'source ~/.config/fish/config.fish'
abbr psg 'ps aux | grep'
abbr rub 'ru -b'
abbr ruk 'ru -k'
abbr olh 'open http://localhost:8080/'
abbr bun 'bundle'
abbr bi 'bundle install'
abbr be 'bundle exec'
abbr gemb "gem build *.gemspec"
abbr gemp "gem push *.gem; rm *.gem"
abbr rsync-synchronize "rsync -avzu --delete --progress -h" # src dst
abbr hk 'heroku'
abbr hkc 'heroku apps:create --region eu --addons mongolab'
abbr g git
abbr gst 'git status -sb' # gs is ghostscript
abbr gsm 'git submodule'
abbr gp 'git push'
abbr gl 'git pull'
for r in nas heroku github web origin admin staging
  set -l initial (string sub --length 1 $r)
  abbr "gp"$initial"m" "git push $r master"
  abbr "gl"$initial"m" "git pull $r master"
end
abbr randhex "openssl rand -hex 64"
abbr tmux "TERM=screen-256color-bce tmux"
abbr myip 'dig +short myip.opendns.com @resolver1.opendns.com'
abbr localip 'ifconfig | awk '\''$1=="inet" {print $2}'\'''
abbr speed 'speedtest-cli'

if test (uname -s) = "Darwin"
  abbr ls 'ls -1AFG'
  abbr br 'brew'
  abbr brud 'brew update; echo -e "\nOutdated:\n"; set_color red; brew outdated; set_color normal'
  abbr brod 'brew outdated'
  abbr brug 'brew upgrade'
  abbr brcu 'brew cleanup -s; rm -rf (brew --cache)'
  abbr brcul 'brew leaves | xargs brew cleanup; rm -rf (brew --cache)'
  abbr brup 'brew update; brew upgrade; brew leaves | xargs brew cleanup'
  abbr dns 'dscacheutil -flushcache; and sudo killall -HUP mDNSResponder'
  abbr whisper 'say -v "Whisper"'
  abbr et 'osascript -e "tell application \"Finder\" to empty trash"'
  abbr showdotfiles "defaults write com.apple.finder AppleShowAllFiles -bool true; and killall Finder"
  abbr hidedotfiles "defaults write com.apple.finder AppleShowAllFiles -bool false; and killall Finder"
  abbr showdesktop "defaults write com.apple.finder CreateDesktop -bool true; and killall Finder"
  abbr hidedesktop "defaults write com.apple.finder CreateDesktop -bool false; and killall Finder"
  abbr softup 'sudo softwareupdate'
  abbr softupall 'sudo softwareupdate -i -a'
  abbr restart 'sudo shutdown -r now'
  abbr chrome 'open -a "Google Chrome"'
end

if type -q pacman
  abbr pacug 'sudo pacman -Syu'
end


