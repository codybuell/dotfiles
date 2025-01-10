-- vim.api.nvim_create_user_command('ChatGPT', function()
--   local has_shellbot, shellbot = pcall(require, 'chatbot')
--   if not has_shellbot then
--     vim.api.nvim_err_writeln("error: could not require 'chatbot'; is the submodule initialized?")
--     return
--   end
--   if vim.env['SHELLBOT'] == nil or vim.fn.executable(vim.env['SHELLBOT']) ~= 1 then
--     vim.api.nvim_err_writeln('error: SHELLBOT does not appear to be executable')
--     return
--   end
--   shellbot.chatbot()
-- end, {})


-- mapping to submit is in ftplugin/shellbot.lua


local has_shellbot = pcall(require, 'chatbot')
if has_shellbot then

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

  -- capture api keys
  local anthropic_api_key = vim.env['ANTHROPIC_API_KEY']
  local openai_api_key = vim.env['OPENAI_API_KEY']

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

  -- Set up an autocmd to stop me from accidentally quitting vim when shellbot is
  -- the only thing running in it. I do this all the time, losing valuable state.
  vim.api.nvim_create_autocmd('QuitPre', {
    pattern = '*',
    callback = function()
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
    end,
  })
else
  local print_error = function()
    vim.api.nvim_err_writeln('error: SHELLBOT does not appear to be executable')
  end
  vim.api.nvim_create_user_command('ChatGPT', print_error, {})
  vim.api.nvim_create_user_command('ChatGPTX', print_error, {})
  vim.api.nvim_create_user_command('Claude', print_error, {})
  vim.api.nvim_create_user_command('Opus', print_error, {})
end
