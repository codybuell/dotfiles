local copilot_instructions = require("CopilotChat.prompts").COPILOT_INSTRUCTIONS

local custom_instructions = [[
You should also:
* Keep responses as concise as possible. Be pithy unless asked for more context.
* When providing code changes only show the relevant code plus a few extra lines above and below for context.
* When providing code changes, show the relevant code in a `diff` format using Markdown. Ensure the syntax highlighting of the actual language is preserved. For example:

```diff
```python
- old line of code
+ new line of code
```
```
]]

require("CopilotChat").setup {
  -- context = 'buffers',
  system_prompt = copilot_instructions .. custom_instructions,
  show_help = false,
  mappings = {
    complete = {
      insert = '<Tab>',
    },
    close = {
      -- normal = 'q',
      normal = 'gq',
      insert = '<C-c>',
    },
    reset = {
      normal = '<C-l>',
      insert = '<C-l>',
    },
    submit_prompt = {
      -- normal = '<CR>',
      -- insert = '<C-s>',
      normal = '<C-s>',
      insert = '<C-s>'
    },
    toggle_sticky = {
      detail = 'Makes line under cursor sticky or deletes sticky line.',
      normal = 'gr',
    },
    accept_diff = {
      normal = '<C-y>',
      insert = '<C-y>',
    },
    jump_to_diff = {
      normal = 'gj',
    },
    quickfix_diffs = {
      -- normal = 'gq',
      normal = '',
    },
    yank_diff = {
      normal = 'gy',
      register = '"',
    },
    show_diff = {
      normal = 'gd',
    },
    show_info = {
      normal = 'gi',
    },
    show_context = {
      normal = 'gc',
    },
    show_help = {
      normal = 'gh',
    },
  },
}
