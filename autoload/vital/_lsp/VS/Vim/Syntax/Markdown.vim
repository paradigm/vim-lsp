" ___vital___
" NOTE: lines between '" ___vital___' is generated by :Vitalize.
" Do not modify the code nor insert new lines before '" ___vital___'
function! s:_SID() abort
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze__SID$')
endfunction
execute join(['function! vital#_lsp#VS#Vim#Syntax#Markdown#import() abort', printf("return map({'apply': ''}, \"vital#_lsp#function('<SNR>%s_' . v:key)\")", s:_SID()), 'endfunction'], "\n")
delfunction s:_SID
" ___vital___
function! s:apply(...) abort
  if !exists('b:___VS_Vim_Syntax_Markdown')
    runtime! syntax/markdown.vim
    let b:___VS_Vim_Syntax_Markdown = {}
  endif

  let l:bufnr = bufnr('%')
  try
    for [l:mark, l:filetype] in items(s:_get_filetype_map(l:bufnr, get(a:000, 0, {})))
      let l:group = substitute(toupper(l:mark), '\.', '_', 'g')
      if has_key(b:___VS_Vim_Syntax_Markdown, l:group)
        continue
      endif
      let b:___VS_Vim_Syntax_Markdown[l:group] = v:true

      try
        if exists('b:current_syntax')
          unlet b:current_syntax
        endif
        execute printf('syntax include @%s syntax/%s.vim', l:group, l:filetype)
        execute printf('syntax region %s matchgroup=Conceal start=/%s/rs=e matchgroup=Conceal end=/%s/re=s contains=@%s containedin=ALL keepend concealends',
        \   l:group,
        \   printf('^\s*```\s*%s\s*', l:mark),
        \   '\s*```\s*$',
        \   l:group
        \ )
      catch /.*/
        echomsg printf('[VS.Vim.Syntax.Markdown] The `%s` is not valid filetype! You can add `"let g:markdown_fenced_languages = ["FILETYPE=%s"]`.', l:mark, l:mark)
      endtry
    endfor
  catch /.*/
    echomsg string({ 'exception': v:exception, 'throwpoint': v:throwpoint })
  endtry
endfunction

"
" _get_filetype_map
"
function! s:_get_filetype_map(bufnr, filetype_map) abort
  let l:filetype_map = {}
  for l:mark in s:_find_marks(a:bufnr)
    let l:filetype_map[l:mark] = s:_get_filetype_from_mark(l:mark, a:filetype_map)
  endfor
  return l:filetype_map
endfunction

"
" _find_marks
"
function! s:_find_marks(bufnr) abort
  let l:marks = {}

  " find from buffer contents.
  let l:text = join(getbufline(a:bufnr, '^', '$'), "\n")
  let l:pos = 0
  while 1
    let l:match = matchlist(l:text, '```\s*\(\w\+\)', l:pos, 1)
    if empty(l:match)
      break
    endif
    let l:marks[l:match[1]] = v:true
    let l:pos = matchend(l:text, '```\s*\(\w\+\)', l:pos, 1)
  endwhile

  return keys(l:marks)
endfunction

"
" _get_filetype_from_mark
"
function! s:_get_filetype_from_mark(mark, filetype_map) abort
  for l:config in get(g:, 'markdown_fenced_languages', [])
    if l:config !~# '='
      if l:config ==# a:mark
        return a:mark
      endif
    else
      let l:config = split(l:config, '=')
      if l:config[1] ==# a:mark
        return l:config[0]
      endif
    endif
  endfor
  return get(a:filetype_map, a:mark, a:mark)
endfunction

