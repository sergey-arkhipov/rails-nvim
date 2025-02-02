# Description

I really like the rails plugin [tpope/vim-rails: rails.vim: Ruby on Rails power tools](https://github.com/tpope/vim-rails)

Using it in neovim leads to compatibility issues with standard functions and other plugins.

So, this plugin implement some necessary function similar to `rails.vim`

### Goto partials

- `Railsgf` is implemented for partials

It's not interfere with main `gf` and can be add as follow:

```lua
-- Map the custom gf function to gf in Rails files
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'eruby', 'html.erb' },
  callback = function() vim.keymap.set('n', 'gf', ':Railsgf<cr>', { buffer = true, noremap = true, silent = true }) end,
})

```

### Rails objects selectors

Fast transitions to the selection of objects are implemented as command for

| Command     | Selector    |
| ----------- | ----------- |
| Emodel      | models      |
| Econtroller | controllers |
| Eview       | views       |
| Espec       | spec tests  |
| Ehelper     | helpers     |
| Eservice    | services    |

Respectively, first letter is:

- E - edit in new buffer
- S - split current
- V - split current vertically

Pass new name to create new file. Just now, simply create file without standard boilerplate.

You can define self-command or modify existed by pass config parameters as showed below.

### Rails fast moving

Added some user command for fast moving used Rails conventions
Can be useful instead of A and R, allow move from current to selected related object.

| Command | Transitions                 |
| ------- | --------------------------- |
| GM      | goto Model                  |
| GC      | goto Controller             |
| GV      | goto View (required action) |
| GH      | goto Helper                 |
| GS      | goto Spec                   |
| GR      | goto route and search for   |

The plugin is currently in testing phase.

## Installation

- lazy.vim

```lua
{
  'sergey-arkhipov/rails-nvim',
  name = 'rails-nvim',
  config = function() require('rails-nvim').setup() end,
}

```

### Customization

By default directory for objects follow Rails.

```bash
  model_dir = "app/models",
  controller_dir = "app/controllers",
  view_dir = "app/views",
  helper_dir = "app/helpers",
  spec_dir = "spec",
  service_dir = "app/services",

```

You can pass another structure when necessary by setup

```lua
{
  'sergey-arkhipov/rails-nvim',
  name = 'rails-nvim',
  config = function() require('rails-nvim').setup(
    {
      spec_dir = "rspec",
      service_dir = "services",
    }
  ) end,
}

```

User commands are created by adding the letters E V S respectively to the directory name in the configuration.

So, `model_dir` will be `Emodel`, `Smodel` and `Vmodel`.
Change `model_dir` to `m_dir` will Change command to `Em`, `Sm` and `Vm`

You can add mapping for fast moving command, for example

Abbr `gr` - go rails ... for memorize

```lua
{
    keys = {

    { 'gr', '', desc = 'Rails fast move' },
    { 'grc', '<cmd>GC<cr>', desc = 'Controller' },
    { 'grh', '<cmd>GH<cr>', desc = 'Helper' },
    { 'grm', '<cmd>GM<cr>', desc = 'Model' },
    { 'grr', '<cmd>GR<cr>', desc = 'Route' },
    { 'grt', '<cmd>GS<cr>', desc = 'Spec' },
    { 'grv', '<cmd>GV<cr>', desc = 'View' },
  },

}

```
