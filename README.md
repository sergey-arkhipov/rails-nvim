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
