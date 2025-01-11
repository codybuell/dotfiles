local has_treesj, treesj = pcall(require, 'treesj')
if has_treesj then
  treesj.setup({
    -- mappings set in plugin/mappings/normal.lua
    use_default_keymaps = false,
  })
end

