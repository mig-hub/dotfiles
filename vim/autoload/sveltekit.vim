if exists('g:loadedPersonalSveltekit')
  finish
endif
let g:loadedPersonalSveltekit = 1

let s:componentNameRegex = '\v\C([A-Z][a-z]*)+'

function! sveltekit#GotoCurrentComponent()
  let l:componentName = expand("<cword>")
  if s:MatchComponentName( l:componentName )
    call sveltekit#ImportComponent( l:componentName )
    call sveltekit#GotoComponent( l:componentName )
  endif
endfunction

function! sveltekit#GotoComponent( componentName )
  let l:componentPath = sveltekit#ComponentPath( a:componentName )
  if filereadable( l:componentPath )
    echom a:componentName .. '.svelte already exists.'
  else
    echom 'Creating ' .. a:componentName .. '.svelte now.'
  endif
  execute 'tabedit' l:componentPath
endfunction

function! sveltekit#ImportAllComponents()
  let l:names = []
  for line in getline(1,'$')
    call substitute( line, '\v\<(' .. s:componentNameRegex .. ')', '\=add(l:names, submatch(1))', 'g')
  endfor
  for name in l:names
    if !sveltekit#IsComponentImported( name )
      echohl WarningMsg
      echom 'Auto import ' .. name .. '.svelte ? (y/n)'
      echohl None
      if nr2char( getchar() ) == 'y'
        call sveltekit#ImportComponent( name )
      endif
    endif
  endfor
endfunction

function! sveltekit#ImportCurrentComponent()
  let l:componentName = expand("<cword>")
  if s:MatchComponentName( l:componentName )
    call sveltekit#ImportComponent( l:componentName )
  endif
endfunction

function! sveltekit#ImportComponent( componentName )
  if !sveltekit#IsComponentImported( a:componentName )
    if a:componentName == 'SvelteMarkdown'
      let l:importStatement = "import SvelteMarkdown from 'svelte-markdown';"
    else
      let l:importStatement = '  import ' .. a:componentName .. ' from "' .. sveltekit#ComponentSveltekitPath( a:componentName ) .. '";'
    endif
    let l:latestImportLineNum = search( '/components/', 'nb' )
    if l:latestImportLineNum == 0
      call s:EnsureScriptTag()
      let l:scriptLineNum = search( '<script>', 'n' )
      call append( l:scriptLineNum, '' )
      call append( l:scriptLineNum, l:importStatement )
      call append( l:scriptLineNum, '' )
    else
      call append( l:latestImportLineNum, l:importStatement )
    endif
  endif
endfunction

function! sveltekit#IsComponentImported( componentName )
  let l:importLineNum = search( '\v\Cimport .*' .. a:componentName, 'n' )
  return l:importLineNum != 0
endfunction

function! sveltekit#ComponentPath( componentName )
  let l:possiblePaths = split( globpath( '.', 'src/lib/components/**/' .. a:componentName .. '.svelte' ), '\n')
  if len( l:possiblePaths ) == 0
    return './src/lib/components/' .. a:componentName .. '.svelte'
  elseif len( l:possiblePaths ) == 1
    return l:possiblePaths[0]
  else
    echoerr 'Error: more than one component found !'
  endif
endfunction

function! sveltekit#ComponentSveltekitPath( componentName )
  return substitute( sveltekit#ComponentPath( a:componentName ), '^.*lib', '$lib', '' )
endfunction

function! s:MatchComponentName( name )
  return a:name =~# '\v^' .. s:componentNameRegex .. '$'
endfunction

function! s:EnsureScriptTag()
  if search( '<script>', 'n' ) == 0
    call append( 0, '</script>' )
    call append( 0, '<script>' )
  endif
endfunction

