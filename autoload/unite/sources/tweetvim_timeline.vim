
function! unite#sources#tweetvim_timeline#define()
  return s:source
endfunction

let s:source = {
      \ 'name': 'tweetvim',
      \ 'hooks' : {},
      \ 'action_table' : {},
      \ 'default_action' : {'common' : 'execute'},
      \ }

function! unite#sources#tweetvim_timeline#start()
  if !exists(':Unite')
    echoerr 'unite.vim is not installed.'
    echoerr 'Please install unite.vim'
    return ''
  endif

  return unite#start(['tweetvim'])
endfunction

function! s:source.gather_candidates(args, context)

  let list = []
  " TODO : refactor
  call extend(list, s:candidates_time_lines())
  call extend(list, s:candidates_time_lines_user())
  call extend(list, s:candidates_lists())

  return list
endfunction

function! s:candidates_time_lines()
  let list = [
        \ 'home_timeline', 
        \ 'mentions', 
        \ 'retweeted_by_me', 
        \ 'retweeted_to_me', 
        \ 'retweets_of_me', 
        \ ]

  return map(list, '{
        \ "word"           : v:val,
        \ "source__method" : v:val
        \ }')
endfunction

function! s:candidates_time_lines_user()
  let credential = tweetvim#verify_credentials()
  " error check
  if empty(credential)
    return []
  endif

  let list = ['favorites']

  return map(list, '{
        \ "word" : v:val ,
        \ "source__method" : v:val,
        \ "source__args"   : [credential.screen_name],
        \ }')
endfunction

function! s:candidates_lists()
  return map(tweetvim#lists(), '{
        \ "word"           : v:val.full_name ,
        \ "source__method" : "list_statuses",
        \ "source__args"   : [v:val.user.screen_name, v:val.slug],
        \ }')
  endfor
endfunction

let s:source.action_table.execute = {'description' : 'show timeline'}
function! s:source.action_table.execute.func(candidate)
  let args = get(a:candidate, 'source__args', [])
  let ret  = call('tweetvim#timeline', [a:candidate.source__method] + args)
endfunction
