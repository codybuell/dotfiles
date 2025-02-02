--------------------------------------------------------------------------------
--                                                                            --
--  Shellbot                                                                  --
--                                                                            --
--  https://github.com/wolffiex/shellbot                                      --
--  https://github.com/wincent/shellbot                                       --
--  https://github.com/codybuell/shellbot                                     --
--                                                                            --
--------------------------------------------------------------------------------

local has_shellbot = pcall(require, 'chatbot')
if has_shellbot then

  ---------------------
  --  Configuration  --
  ---------------------

  -- capture api keys
  local anthropic_api_key = vim.env['ANTHROPIC_API_KEY']
  local openai_api_key = vim.env['OPENAI_API_KEY']

  ---------------
  --  Helpers  --
  ---------------

  -- helper to toggle the shellbot buffer
  local close_existing_shellbot_buffer = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].filetype == 'shellbot' then
        vim.api.nvim_buf_delete(buf, { force = true })
        return true
      end
    end
    return false
  end

  -- Set up wrapper commands for specifically targetting ChatGPT and Claude.
  local shellbot = function(config)
    if close_existing_shellbot_buffer() then
      return
    end
    close_existing_shellbot_buffer()
    local saved_variables = {}
    for _, unset in ipairs(config.unset or {}) do
      saved_variables[unset] = vim.env[unset]
      vim.env[unset] = nil
    end
    for key, value in pairs(config.set or {}) do
      saved_variables[key] = vim.env[key]
      vim.env[key] = value
    end
    -- print(vim.fn.system('echo $ANTHROPIC_API_KEY'))
    -- print(vim.fn.system('echo $OPENAI_API_KEY'))
    -- print(vim.fn.system('echo $ANTHROPIC_MODEL'))
    -- print(vim.fn.system('echo $OPENAI_MODEL'))
    pcall(function()
      vim.cmd('Shellbot')
    end)
    -- for key, value in pairs(saved_variables) do
    --   vim.env[key] = value
    --   vim.fn.system(key .. "=" .. value)
    -- end
  end

  -------------
  --  Setup  --
  -------------

  vim.api.nvim_create_user_command('ChatGPT', function()
    shellbot({
      unset = { 'ANTHROPIC_API_KEY' },
      set = {
        OPENAI_MODEL = 'gpt-4o',
        OPENAI_API_KEY = openai_api_key,
      },
    })
  end, {})

  vim.api.nvim_create_user_command('ChatGPTX', function()
    shellbot({
      unset = { 'ANTHROPIC_API_KEY' },
      set = {
        OPENAI_MODEL = 'o1-mini',
        OPENAI_API_KEY = openai_api_key,
      },
    })
  end, {})

  vim.api.nvim_create_user_command('Claude', function()
    shellbot({
      unset = { 'OPENAI_API_KEY' },
      set = {
        ANTHROPIC_MODEL = 'claude-3-5-sonnet-20241022',
        ANTHROPIC_API_KEY = anthropic_api_key,
      },
    })
  end, {})

  vim.api.nvim_create_user_command('Opus', function()
    shellbot({
      unset = { 'OPENAI_API_KEY' },
      set = {
        ANTHROPIC_MODEL = 'claude-3-opus-20240229',
        ANTHROPIC_API_KEY = anthropic_api_key,
      },
    })
  end, {})

  ----------------
  --  Mappings  --
  ----------------

  --------------------
  --  Autocommands  --
  --------------------

  local augroup = buell.util.augroup
  local autocmd = buell.util.autocmd

  augroup('BuellShellbot', function()
    autocmd('Filetype', 'shellbot', function()
      vim.keymap.set({ 'i', 'n' }, '<C-s>', ChatBotSubmit, { buffer = true })
    end)
    autocmd('QuitPre', '*', function()
      local buftype = vim.bo.buftype
      local filetype = vim.bo.filetype
      local win_count = #vim.api.nvim_tabpage_list_wins(0)

      if filetype == 'shellbot' and buftype == 'nofile' and win_count == 1 then
        vim.api.nvim_err_writeln('')
        vim.api.nvim_err_writeln('Use :q! if you really want to quit the last shellbot window')
        vim.api.nvim_err_writeln('')

        -- Will make Neovim abort the quit with:
        --
        --    E37: No write since last change
        --    E162: No write since last change for buffer "[No Name]"
        --
        vim.bo.buftype = ''
      end
    end)
  end)

end
