[![LuaRocks](https://img.shields.io/luarocks/v/mimparat132/kube.nvim?logo=lua&color=purple)](https://luarocks.org/modules/mimparat132/kube.nvim)
# kube.nvim

## Installation

### Libyaml

- kube.nvim uses the lyaml luarock. lyaml is a wrapper around the libyaml implementation ( written in C ). In order to use the lyaml rock, you need to have `libyaml` installed on your system. To install this dependency on debian based systems:

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

- The following functions are exposed to be bound to keybindings of your choice:
  - `get_k8s_metadata()`: This function when called in a buffer containing a single kubernetes manifest will generate a kustomize target spec and copy it to your clipboard. The following snippet is an example output if given an ingress input:
  ```yaml
  - target:
      group: networking.k8s.io
      name: test-ingress
      kind: Ingress
      version: v1
  ```
  - `encrypt_line()`: This function, when called with your cursor on a line that contains a key value pair in a kubernetes secret, will encrypt the value in the key value pair. The encrypted value is copied to your clipboard.
  - `decrypt_line()`: This function, when called with your cursor on a line that contains a key value pair in a kubernetes secret, will decrypt the value in the key value pair. The decrypted value is copied to your clipboard.
  - `get_kustomize_path()`: Will copy a kustomize patch patch compliant string to the system clipboard and display a notification of what has been copied.
  - `get_yq_path()`: Will copy a yq compliant search string to the system clipboard and display a notification of what has been copied.
- These functions are exposed at neovim runtime. To use them in a file you can call them directly from the command line:

```lua
:lua (require"kube").get_kustomize_path()
```

- Or you can bind them to a key and source them via your neovim config:

```lua
map('n', '<leader>b', ':lua require"kube".get_kustomize_path()<CR>', {noremap = true, silent = false})
map('n', '<leader>i', ':lua require"kube".get_yq_path()<CR>', {noremap = true, silent = false})
```
