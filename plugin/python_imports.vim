if exists('g:loaded_python_imports')
  finish
endif
let g:loaded_python_imports = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? PyImport :call python_imports#PythonInsert(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
