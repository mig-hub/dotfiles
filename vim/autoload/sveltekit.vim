function! sveltekit#GotoCurrentComponent()
  let l:componentName = expand("<cword>")
  call sveltekit#ImportComponent( l:componentName )
  call sveltekit#GotoComponent( l:componentName )
endfunction

function! sveltekit#ImportCurrentComponent()
  let l:componentName = expand("<cword>")
  call sveltekit#ImportComponent( l:componentName )
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

function! sveltekit#ImportComponent( componentName )
  let l:importLineNum = search( 'import ' .. a:componentName )
  if l:importLineNum == 0
    let l:importStatement = '  import ' .. a:componentName .. ' from "' .. sveltekit#ComponentSveltekitPath( a:componentName ) .. '";'
    let l:latestImportLineNum = search( '/components/', 'b' )
    if l:latestImportLineNum == 0
      call sveltekit#EnsureScriptTag()
      let l:scriptLineNum = search( '<script>' )
      call append( l:scriptLineNum, '' )
      call append( l:scriptLineNum, l:importStatement )
      call append( l:scriptLineNum, '' )
    else
      call append( l:latestImportLineNum, l:importStatement )
    endif
  else
    echom a:componentName .. '.svelte is already imported.'
  endif
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

function! sveltekit#EnsureScriptTag()
  if search( '<script>' ) == 0
    call append( 0, '</script>' )
    call append( 0, '<script>' )
  endif
endfunction

