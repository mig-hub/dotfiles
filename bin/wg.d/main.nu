def "main list-schemas" [
  --with-fields (-f)
] {
  config | get schemas | each {|s|
    print $s.name
    if $with_fields and ($s.fields? | is-not-empty) {
      $s.fields | each {|f|
        print $"  ($f.name) \(($f.type? | default 'string')\)"
      }
    }
  } | ignore
}
