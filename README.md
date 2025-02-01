# Description

I really like the rails plugin [tpope/vim-rails: rails.vim: Ruby on Rails power tools](https://github.com/tpope/vim-rails)

Using it in neovim leads to compatibility issues with standard functions and other plugins.

So, this plugin implement some necessary function similar to `rails.vim`

- `gf` is implemented for partials, which does not interfere with the main `gf`

Fast transitions to the selection of objects are implemented for

- models (Emodel)
- controllers (Econtroller)
- views (Eview)
- tests specs (Espec)

Pass new name to create new file. Just now simply create file without standard boilerplate

The logic of transition to A (alternative) and R (related) files is partially implemented.
For example, the controller file for this model is called from the model file.

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
