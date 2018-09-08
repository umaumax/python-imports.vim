if !exists('g:loaded_python_imports')
  finish
endif
let g:loaded_python_imports = 1

let s:save_cpo = &cpo
set cpo&vim

function s:PythonAddImport(import)
  let l:oldpos = getpos(".")

  " First check if this already gets imported
  call cursor(1, 1)
  if search("\\m^[ \t]*" . a:import . "[ \t]*$", "cn") != 0
    call setpos(".", l:oldpos)
    return
  end

  " Locate the first import line
  call cursor(1, 1)
  let l:firstImport = search("\\m^[ \t]*\\(from\\|import\\)[ \t]", "cn")
  if l:firstImport == 0
    " Search for the first non-comment line and use that one
    call cursor(1, 1)
    let l:firstImport = 1
    while 1
      let l:firstImport += 1
      let l:found = search("\\m^[ \t]*#", "", line("$"))
      if l:found == 0 || l:found > l:firstImport
        break
      end
    endwhile
  end
  if line("$") < l:firstImport
    let l:firstImport = line("$")
  end

  " Insert the new import
  call cursor(l:firstImport, 1)
  exe "normal I\<CR>\<ESC>"
  let l:oldpos[1] += 1
  call setline(l:firstImport, a:import)

  " Resort the imports
  call cursor(l:firstImport, 1)
  let l:lastImport = l:firstImport
  while 1
    let l:found = search("\\m^[ \t]*\\(from\\|import\\)[ \t]", "", line("$"))
    if l:found == 0 || l:found > l:lastImport + 1
      break
    end
    let l:lastImport += 1
  endwhile
  exe "normal :" . l:firstImport . "," . l:lastImport . "sort\<CR>"

  " Position the cursor where it was before
  let l:oldpos[2] += 1
  call setpos(".", l:oldpos)

  " Return an empty string to allow to use this in snippets
  return ""
endfunction

function python_imports#PythonInsert(...)
  let l:import = get(a:, 1, '')
  if l:import == ""
    let l:import = substitute(expand("<cWORD>"), "\\m\\.[^\\.]*$", "", "")
    let l:import = substitute(l:import, "\\m^.*[(]", "", "")
    let l:import = substitute(l:import, "\\m\\W\\+$", "", "")
    let l:import = substitute(l:import, '\..*', "", "")
    if match(l:import, "[^A-Za-z0-9_.-]") != -1
      let l:import = ""
    end
    if l:import == ""
      let l:import = input("Module to import: ")
      if l:import == ""
        return
      endif
    end
  endif
  call s:PythonAddImport("import " . l:import)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
