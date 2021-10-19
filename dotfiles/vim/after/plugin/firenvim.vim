""""""""""""""""
"              "
"   firenvim   "
"              "
""""""""""""""""

" bail if firenvim is not installed
if !buell#helpers#PluginExists('firenvim')
  finish
endif

" requires firenvim plugin in chrome or firefox

" firevim specific settings
if exists('g:started_by_firenvim')

  " drop our status bar
  set laststatus=0

  " get rid of our eol character
  set lcs=tab:>-,trail:.,extends:»,precedes:«

  " configurations, global and site specific, manually launch with shortcut
  " set in chrome://extensions/shortcuts or about://addons in firefox, use
  " firenvim instead of the standard vim command line, simplifies interface
  let g:firenvim_config = { 
  \   'globalSettings': {
  \     'alt': 'all',
  \    },
  \   'localSettings': {
  \     '.*': {
  \       'cmdline': 'firenvim',
  \       'priority': 0,
  \       'selector': 'textarea',
  \       'takeover': 'never',
  \     },
  \   }
  \ }
endif

function s:SetUpFirenvimColorscheme()
  
  " set a light colorscheme so it doesn't clash with the native webpage
  colorscheme base16-github
  " colorscheme base16-default-light
  " colorscheme base16-google-light
  " colorscheme base16-grayscale-light
  " colorscheme base16-tomorrow

endfunction

if has('autocmd')
  augroup BuellFirenvimAutocmds
    autocmd!

    if exists('g:started_by_firenvim')
      autocmd ColorScheme * call s:SetUpFirenvimColorscheme()
    endif

  augroup END
endif
