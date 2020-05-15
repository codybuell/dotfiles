""""""""""""""""
"              "
"   firenvim   "
"              "
""""""""""""""""

" requires firenvim plugin in chrome or firefox

" firevim specific settings
if exists('g:started_by_firenvim')

  " set a light colorscheme so it doesn't clash with the native webpage
  colorscheme base16-github
  " colorscheme base16-default-light
  " colorscheme base16-google-light
  " colorscheme base16-grayscale-light
  " colorscheme base16-tomorrow

  " drop our status bar
  set laststatus=0

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
