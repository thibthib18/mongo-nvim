if exists('g:loaded_mongo_nvim') | finish | endif

augroup mongo_nvim_autocmds
  au!
  au BufWriteCmd mongo_nvim://* lua require'mongo-nvim.buffer'.save()
augroup END

let g:loaded_mongo_nvim = 1
