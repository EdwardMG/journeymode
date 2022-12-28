" Wed 28 Dec 2022 15:49:51 EST
" ----------------------------
    " this never works out, because the macro will play literally,
    " so unless you want to record the macro in journey mode, it won't
    " do what you want... maybe if it exits journeymode first, I don't know
    " I'm more likely to have wanted to <Space>f and get frustrated than use
    " this legitimately, let's drop it
    nno <silent><nowait> <Space> @q

" Wed 28 Dec 2022 15:49:15 EST
" ----------------------------
    " I don't use this much and it has an outside dependency... Let's just
    " drop it
    nno u :call CycleUppercaseMarks(1)<CR>
    nno i :call CycleUppercaseMarks(-1)<CR>

" Wed 28 Dec 2022 15:48:23 EST
" ----------------------------
    nno r :Rg<CR>

" Wed 28 Dec 2022 15:47:29 EST
" ----------------------------
    vno h <C-u>
    vno n <C-d>

" Wed 28 Dec 2022 15:45:54 EST
" ----------------------------
    " meh
    " nno e :call GoToPreviousFold()<CR>
    " nno <nowait> d :call GoToNextFold()<CR>

" Wed 28 Dec 2022 15:45:50 EST
" ----------------------------
    " nno <nowait> d :let g:journey_diff_mode=!g:journey_diff_mode<CR>
    " horizontal movement
    " nno , 10zh
    " nno . 10zl

" Wed 28 Dec 2022 15:43:14 EST
" ----------------------------
    " nno f :Files<CR>
    " nno a :Files app<CR>
    " nno s :Files spec<CR>
    " nno v :Files ~/.vim<CR>

" Wed 28 Dec 2022 15:42:56 EST
" ----------------------------
    nnoremap <silent> <Leader>l ml:execute 'match Search /\%'.line('.').'l/'<CR>

" Wed 28 Dec 2022 15:42:02 EST
" ----------------------------
    " vno <silent> dl :<C-u>call JourneyMode()<CR>:call LineMode()<CR>gv
    " vno <silent> dk :<C-u>call JourneyMode()<CR>:call SurveyMode()<CR>gv

" Wed 28 Dec 2022 15:42:00 EST
" ----------------------------
    nno <silent> dl :call JourneyMode()<CR>:call LineMode()<CR>
    nno <silent> dk :call JourneyMode()<CR>:call SurveyMode()<CR>

" Wed 28 Dec 2022 15:41:17 EST
" ----------------------------
    nno <silent> k :call JourneyDiffHelper('P')<CR>
    nno <silent> j :call JourneyDiffHelper('N')<CR>

" Wed 28 Dec 2022 15:40:17 EST
" ----------------------------
" If I were to make more modes, the simplest way to keep them from
" creating conflicts and making undoing their mappings easier would
" be to set g:submode = name of mode or something like that, and always
" unset it before turning on the next mode
" it does occur to me though, that generally with these submodes I'm going
" to be overwriting letters I never normally overwrite, for their ease of
" access, so I'm probably never going to have to actually save remaps to
" return to... but some foundation is here if I ever were to

" Wed 28 Dec 2022 15:39:51 EST
" ----------------------------
" stolen from internet
" doesnt work! :(
" function! JumpToNextBufferInJumplist(dir) " 1=forward, -1=backward
"     let jl = getjumplist() | let jumplist = jl[0] | let curjump = jl[1]
"     let jumpcmdstr = a:dir > 0 ? "\<C-O>" : "\<C-I>"
"     " let jumpcmdchr = a:dir > 0 ? '^O' : '^I'    " <C-I> or <C-O>
"     let searchrange = a:dir > 0 ? range(curjump+1,len(jumplist))
"                               \ : range(curjump-1,0,-1)
"     for i in searchrange
"         if jumplist[i]["bufnr"] != bufnr('%')
"             let n = (i - curjump) * a:dir
"             echo "Executing ".jumpcmdstr." ".n." times."
"             execute "silent normal! ".n.jumpcmdstr
"             break
"         endif
"     endfor
" endfunction

" Wed 28 Dec 2022 15:39:39 EST
" ----------------------------
fu! JourneyDiffHelper(direction)
  se lazyredraw
  " my notes don't actually comeback when I -=BufEnter after
  " se ei=BufEnter
  try
    if matchstr(expand('%'), 'fugitive') != "" | :q | endif
    if a:direction == 'N'
      :cnext
    else
      :cprevious
    endif
    if !g:journey_diff_mode
      exe 'normal zR'
    endif
  catch
    se nolazyredraw
    if g:journey_diff_mode
      :only
      :Gdiff master
    endif
    return
  endtry
  if g:journey_diff_mode
    only
    se ma " modifiable... sometimes off annoyingly
    " git rev-list --count HEAD ^master
    " Gdiff HEAD^ would show difference from last commit
    "
    " this shows hash of first commit after master for branch
    " git rev-list HEAD ^master | tail -n 1
    " let hash_before_master = system('git rev-list HEAD ^master | tail -n 1')
    " :Gdiff master " this is working well now
    " something specific about this is triggering modifiable is off, but I
    " don't know what... 
    call g:NyaoFn.DiffAgainstCommitBeforeBranch()
    " :Gdiff
    " for some reason this doesn't work... maybe something asyc about :Gdiff
    " exe 'normal zR'
  endif
  " se ei-=BufEnter
  se nolazyredraw
endfu

" Wed 28 Dec 2022 15:31:52 EST
" ----------------------------
fu! s:DateHeader()
  let r = split(system('date'), "\n")[0]
  return [s:CommentCharacter().r, s:CommentCharacter().substitute(r, '.', '-', 'g' ) ]
endfu

