if exists('g:loadedPersonalAstro')
  finish
endif
let g:loadedPersonalAstro = 1

let s:componentNameRegex = '\v\C([A-Z][a-z]*)+'

function! astro#GotoCurrentComponent()
  let l:componentName = expand("<cword>")
  if s:MatchComponentName( l:componentName )
    call astro#ImportComponent( l:componentName )
    call astro#GotoComponent( l:componentName )
  endif
endfunction

function! astro#GotoComponent( componentName )
  let l:componentPath = astro#ComponentPath( a:componentName )
  if filereadable( l:componentPath )
    echom a:componentName .. '.astro already exists.'
  else
    echom 'Creating ' .. a:componentName .. '.astro now.'
  endif
  execute 'tabedit' l:componentPath
endfunction

function! astro#ImportAllComponents()
  let l:names = []
  for line in getline(1,'$')
    call substitute( line, '\v\<(' .. s:componentNameRegex .. ')', '\=add(l:names, submatch(1))', 'g')
  endfor
  for name in l:names
    if !astro#IsComponentImported( name )
      echohl WarningMsg
      echom 'Auto import ' .. name .. '.astro ? (y/n)'
      echohl None
      if nr2char( getchar() ) == 'y'
        call astro#ImportComponent( name )
      endif
    endif
  endfor
endfunction

function! astro#ImportCurrentComponent()
  let l:componentName = expand("<cword>")
  if s:MatchComponentName( l:componentName )
    call astro#ImportComponent( l:componentName )
  endif
endfunction

function! astro#ImportComponent( componentName )
  if !astro#IsComponentImported( a:componentName )
    " if a:componentName == 'SvelteMarkdown'
    "   let l:importStatement = "import SvelteMarkdown from 'svelte-markdown';"
    " else
    "   let l:importStatement = '  import ' .. a:componentName .. ' from "' .. astro#ComponentAstroPath( a:componentName ) .. '";'
    " endif
    let l:importStatement = '  import ' .. a:componentName .. ' from "' .. astro#ComponentAstroPath( a:componentName ) .. '";'
    let l:latestImportLineNum = search( '/components/', 'nb' )
    if l:latestImportLineNum == 0
      call s:EnsureFrontmatter()
      let l:frontmatterLineNum = search( '---', 'n' )
      call append( l:frontmatterLineNum, '' )
      call append( l:frontmatterLineNum, l:importStatement )
      call append( l:frontmatterLineNum, '' )
    else
      call append( l:latestImportLineNum, l:importStatement )
    endif
  endif
endfunction

function! astro#IsComponentImported( componentName )
  let l:importLineNum = search( '\v\Cimport .*' .. a:componentName, 'n' )
  return l:importLineNum != 0
endfunction

function! astro#ComponentPath( componentName )
  let l:possiblePaths = split( globpath( '.', 'src/components/**/' .. a:componentName .. '.astro' ), '\n')
  if len( l:possiblePaths ) == 0
    return './src/components/' .. a:componentName .. '.astro'
  elseif len( l:possiblePaths ) == 1
    return l:possiblePaths[0]
  else
    echoerr 'Error: more than one component found !'
  endif
endfunction

function! astro#ComponentAstroPath( componentName )
  return substitute( astro#ComponentPath( a:componentName ), '^.*components', '../components', '' )
endfunction

function! s:MatchComponentName( name )
  return a:name =~# '\v^' .. s:componentNameRegex .. '$'
endfunction

function! s:EnsureFrontmatter()
  if search( '---', 'n' ) == 0
    call append( 0, '' )
    call append( 0, '---' )
    call append( 0, '---' )
  endif
endfunction


