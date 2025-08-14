--------------------------------------------------------------------------------
--                                                                            --
--  Snacks                                                                    --
--                                                                            --
--  https://github.com/folke/snacks.nvim                                      --
--                                                                            --
--------------------------------------------------------------------------------

local has_snacks, snacks = pcall(require, 'snacks')
if not has_snacks then
  return
end

snacks.setup({
  ----------------------------
  --  Custom Window Styles  --
  ----------------------------
  styles = {
    above_cursor = {
      backdrop = false,
      position = 'float',
      border = 'rounded',
      title_pos = 'left',
      height = 1,
      noautocmd = true,
      relative = 'cursor',
      row = -3,
      col = 0,
      wo = {
        cursorline = false,
        winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder",
        signcolumn = "no",
        foldcolumn = "0",
      },
      bo = {
        filetype = 'snacks_input',
        buftype = 'prompt',
      },
      b = {
        completion = true,
      },
      keys = {
        n_esc = { '<esc>', { 'cmp_close', 'cancel' }, mode = 'n', expr = true },
        i_esc = { '<esc>', { 'cmp_close', 'stopinsert' }, mode = 'i', expr = true },
        i_cr = { '<cr>', { 'cmp_accept', 'confirm' }, mode = 'i', expr = true },
        i_tab = { '<tab>', { 'cmp_select_next', 'cmp', 'fallback' }, mode = 'i', expr = true },
        i_ctrl_w = { '<c-w>', '<c-s-w>', mode = 'i', expr = true },
        i_up = { '<up>', { 'hist_up' }, mode = { 'i', 'n' } },
        i_down = { '<down>', { 'hist_down' }, mode = { 'i', 'n' } },
        gq = 'cancel',
        q = 'cancel',
      },
    },
  },

  --------------------------------
  --  Component Configurations  --
  --------------------------------
  input = {
    enabled = true,
    icon = "",
    win = {
      style = 'above_cursor',
    },
  },
  picker = {
    enabled = true,
  },
  notifier = {
    enabled = true,
  },
})
