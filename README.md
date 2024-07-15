# kube.nvim

## Installation

### Libyaml

- kube.nvim uses the lyaml luarock. lyaml is a wrapper around the libyaml implementation ( written in C ). In order to use the lyaml rock, you need to have `libyaml` installed on your system.
```bash
sudo apt-get install libyaml-dev
```

### `lazy.nvim`

- To install kube.nvim via lazy, first ensure that you have `luarocks` installed on your system.
On Linux/Mac, this involves installing using your system's package manager.
```lua
{
    "mimparat132/kube.nvim",
}
```

## Usage

- Currently, only two functions are exposed: `get_kustomize_path()` and `get_yq_path()`
- `get_kustomize_path()`: will copy a kustomize patch patch compliant string to the system clipboard and display a notification of what has been copied.
- `get_yq_path()`: will copy a yq compliant search string to the system clipboard and display a notification of what has been copied.
- These functions are exposed at neovim runtime. To use them in a file you can call them directly from the command line:
```lua
:lua (require"kube").get_kustomize_path()
```
- Or you can bind them to a key and source them via your neovim config:
```lua
map('n', '<leader>b', ':lua require"kube".get_kustomize_path()<CR>', {noremap = true, silent = false})
map('n', '<leader>i', ':lua require"kube".get_yq_path()<CR>', {noremap = true, silent = false})
```
