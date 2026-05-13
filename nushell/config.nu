$env.config.buffer_editor = "nvim"
$env.config.edit_mode = 'vi'
$env.config.show_banner = false

# plugin use gstat

alias fg = job unfreeze
alias vi = nvim
alias vim = nvim

# $env.PROMPT_COMMAND = {||
#   let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
#     null => $env.PWD
#     '' => '~'
#     $relative_pwd => ([~ $relative_pwd] | path join)
#   }
#   let branch = (gstat | get branch)
#   let branch_indicator = if ($branch == 'no_branch') {
#     ''
#   } else {
#     $"  ($branch)"
#   }
#   ([ (ansi blue) $dir (ansi reset) $branch_indicator ] | str join)
# }
# $env.PROMPT_COMMAND_RIGHT = {||
#   let datetime = ([
#     (date now | format date '%d/%m/%Y %H:%M')
#   ] | str join)
#   ([ (ansi magenta) $datetime (ansi reset) ] | str join)
# }
# $env.PROMPT_INDICATOR = " > "
# $env.PROMPT_INDICATOR_VI_INSERT = " > "
# $env.PROMPT_INDICATOR_VI_NORMAL = " : "
# $env.PROMPT_MULTILINE_INDICATOR = " >>> "

# Shortcut for yazi so that it can change director on quit
# Use uppercase Q to quit without changing directory
def --env y [...args] {
  let tmp = (mktemp -t "yazi-cwd.XXXXXX")
  ^yazi ...$args --cwd-file $tmp
  let cwd = (open $tmp)
  if $cwd != $env.PWD and ($cwd | path exists) {
    cd $cwd
  }
  rm -fp $tmp
}

