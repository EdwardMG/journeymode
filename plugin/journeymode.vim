fu! AddToAlternateQF( qf_name, filename, lnum, text )
  if (!exists('g:'.a:qf_name))
    exe 'let g:'.a:qf_name.'=[]'
  endif

  exe 'let alt_qf=g:'.a:qf_name

  return add(alt_qf, {
        \ "filename": a:filename,
        \ "lnum":     a:lnum,
        \ "text":     a:text,
        \ "nr": -1 })
endfu

fu! AddToJourneyAltQf()
  call AddToAlternateQF('journey_qf', expand('%'), line('.'), '')
  if !exists('g:qf_registers') | let g:qf_registers={} | endif
  let g:qf_registers['journey_qf'] = deepcopy(g:journey_qf)
  echo 'Set '.expand('%').':'.line('.')
endfu

fu! LoadJourneyAltQf()
  let g:qf_list_before_journey = GetQFList()
  let g:qf_list_before_journey_string = string( g:qf_list_before_journey )
  call setqflist( g:journey_qf )
  call SetQFs()
endfu

command! Joqf call LoadJourneyAltQf()
command! Joqfreturn call setqflist( g:qf_list_before_journey )

fu! g:GoToNextFold()
    let l:ln = line('.')
    if !foldlevel( l:ln )
        exe 'normal! zjzo'
    else
        if foldclosed( l:ln ) != -1 " not a closed fold
            exe 'normal! zo'
        else
            exe 'normal! zczjzo'
        endif
    endif
endfu

fu! g:GoToPreviousFold()
    let l:ln = line('.')
    if !foldlevel( l:ln )
        exe 'normal! zkzo'
    else
        if foldclosed( l:ln ) != -1 " not a closed fold
            exe 'normal! zo'
        else
            exe 'normal! zczkzo'
        endif
    endif
endfu

fu! JourneyMode()
  if exists('g:nyao_modes')
    call DeactivateOtherModes('JourneyMode')
  endif
  if !exists('g:journey_mode')
    let g:journey_mode = 1
    call add(g:nyao_modes, { -> g:journey_mode })
  else
    let g:journey_mode = !g:journey_mode
  endif
  if !exists('g:jor_old_mappings')   | let g:jor_old_mappings   = {} | endif
  if !exists('g:jor_old_v_mappings') | let g:jor_old_v_mappings = {} | endif

  if g:journey_mode | let g:nyao_active_mode = 'JourneyMode' | endif

  let keys_to_map   = ['j', 'k', 'h', 'n', 'u', 'i', 'm', '<Tab>', 'o', 'p', 'r', 's', 'v', 'f', 'b', 'a', 's', 'v', ',', '.', 'q', 'e', 'd', 'c', 'dl', 'dk']
  let v_keys_to_map = ['h', 'n', '<Tab>']

  if g:journey_mode
    for n in keys_to_map   | let g:jor_old_mappings[ n ]   = maparg( n, 'n') | endfor
    for n in v_keys_to_map | let g:jor_old_v_mappings[ n ] = maparg( n, 'v') | endfor

    if &bg=="dark"
      hi StatusLine ctermbg=136 ctermfg=black
    else
      hi StatusLine ctermbg=white ctermfg=brown
    endif
    nno <silent> k :cprevious<CR>zR
    nno <silent> j :cnext<CR>zR

    nno h <C-u>
    nno n <C-d>
    nno o <C-o>
    nno p <C-i>

    " search by constant in ruby
    nno f :call search('\v^[^#][^A-Z]*\zs[A-Z][A-z:]*\ze', 'we')<CR>
    nno b :call search('\v^[^#][^A-Z]*\zs[A-Z][A-z:]*\ze', 'wbe')<CR>

    nno <nowait> c :call RecordAndJump()<CR>

    " forgot I wrote this, it's actually a very nice idea, similar to cycle
    " marks, just generating points of interest. Could be helpful for dwarf
    " mode
    nno <nowait> m :call AddToJourneyAltQf()<CR>
    let g:journey_diff_mode = 0
    nno q :call JourneyMode()<CR>@q:call JourneyMode()<CR>

    nno <nowait> , :call g:GoToNextFold()<CR>

    nno <silent> <Tab> :call JourneyMode()<CR>

    vno <silent><nowait> <Tab> :<C-u>call JourneyMode()<CR>gv

    vno h <C-u>
    vno n <C-d>
  else " exit journey mode
    let g:nyao_active_mode = ""
    " this technique is insufficient for the appregio (key chord) plugin
    " since key chords kinda hurt to type, I don't think I'll miss it
    for n in keys_to_map
      if has_key( g:jor_old_mappings, n )
            \ && type(g:jor_old_mappings[ n ]) == 1
            \ && len(g:jor_old_mappings[ n ]) > 0
        exe 'nno '.n.' '. g:jor_old_mappings[ n ]
      else
        exe 'nno '.n.' '.n
      endif
      if has_key( g:jor_old_mappings, n ) | unlet g:jor_old_mappings[ n ] | endif
    endfor

    if exists('g:nyao_modes')
      call ResetStatusColour()
    endif

    for n in v_keys_to_map
      if has_key( g:jor_old_v_mappings, n )
            \ && type(g:jor_old_v_mappings[ n ]) == 1
            \ && len(g:jor_old_v_mappings[ n ]) > 0
        exe 'vno '.n.' '. g:jor_old_v_mappings[ n ]
      else
        exe 'vno '.n.' '.n
      endif
      if has_key( g:jor_old_v_mappings, n ) | unlet g:jor_old_v_mappings[ n ] | endif
    endfor
  endif
endfu

command! Jor call JourneyMode()

