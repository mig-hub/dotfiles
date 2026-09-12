# Read the config file `webgum.yml` the first time it is called.
# And returns the cached version on subsequent calls.
# The config is saved in `$env.WEBGUM_CONFIG`.
def --env config [
  config_path : string = ./webgum.yml
] {

  if $env.WEBGUM_CONFIG? != null {
    return $env.WEBGUM_CONFIG
  }

  if not ($config_path | path exists) {
    print --stderr $"(ansi red)Missing configuration file(ansi reset): ($config_path)"
    exit 1
  }

  let config = open -r $config_path | from yaml

  if not ($config | is-record)  {
    print --stderr $"(ansi red)Invalid configuration file(ansi reset): ($config_path)"
    exit 1
  }

  mut merged = $config

  if ($config.includes? | is-not-empty) {
    for include_file in $config.includes {
      let include_config = open -r $include_file | from yaml
      if ($include_config | is-record) {
        $merged = ($merged | merge $include_config)
      }
    }
  }

  $env.WEBGUM_CONFIG = $merged
  $merged

}

def is-record [] {
  ($in | describe -d | get type) == 'record'
}

def is-list [] {
  ($in | describe -d | get type) == 'list'
}

