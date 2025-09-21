-- Neovim config to handle Jinja2 templated files with compound filetypes.

local augroup = buell.util.augroup
local autocmd = buell.util.autocmd

-- Map common extensions to Neovim filetypes (extend as you like)
local ext_to_ft = {
  yml = "yaml", yaml = "yaml",
  json = "json", toml = "toml",
  ini = "dosini", conf = "conf",
  tf = "terraform", tfvars = "terraform",
  hcl = "hcl", md = "markdown",
  txt = "text", sh = "sh", bash = "sh",
  py = "python", js = "javascript", ts = "typescript",
  html = "html", xml = "xml",
}

-- Derive base ft and set compound "<base>.jinja2"
local function set_compound_jinja_ft(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  -- grab the token right before .j2/.jinja2 (last sub-extension)
  local ext = name:match("%.([%w_%-%+]+)%.j2$") or name:match("%.([%w_%-%+]+)%.jinja2$")
  if not ext then return end
  local base = ext_to_ft[ext] or ext
  vim.bo[buf].filetype = (base .. ".jinja2")
end

local function setup_jinja_syntax()
  local ft = vim.bo.filetype or ""
  if not ft:match("%.jinja2$") then return end
  vim.cmd([[
    " {{ ... }}
    syntax match jinjaVar /{{\s*.\{-}\s*}}/ containedin=ALL
    highlight def link jinjaVar Identifier
    " OPTIONAL: enable these two for blocks/comments too
    " syntax region jinjaTag start=/{%\s*/ end=/\s*%}/ containedin=ALL
    " syntax region jinjaCmt start=/{#\s*/ end=/\s*#}/ containedin=ALL
    " highlight def link jinjaTag Statement
    " highlight def link jinjaCmt Comment
  ]])
end

augroup('BuellJinjaAutocommands', function()
  autocmd('BufRead,BufNewFile', '*.j2,*.jinja2', function()
    set_compound_jinja_ft(vim.fn.bufnr('%'))
  end)

  autocmd('FileType', '*', setup_jinja_syntax)
end)
