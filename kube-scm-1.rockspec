local MODREV, SPECREV = "scm", "-1"
rockspec_format = "3.0"
package = "kube"
version = MODREV .. SPECREV


package = 'kube'
source = {
      url = 'git://github.com/mimparat132/kube.nvim.git',
}

description = {
   summary = "Kubernetes utilities for use in neovim",
   detailed = [[
        So far, the module contains functions to obtain the
        yq or kustomize path patch form of a yaml path in a
        yaml document.
   ]],
   labels = { "neovim" },
   homepage = "https://github.com/mimparat132/kube.nvim",
   license = "MIT/X11"
}
dependencies = {
   "lua == 5.1",
   "lyaml",
}
build = {}