local kube = require("kube.find_path")

local M = {}

function M.get_yq_path()
    local find_opts = {}
    find_opts["syntax"] = "yq"
    kube.find_path(find_opts)
end

function M.get_kustomize_path()
    local find_opts = {}
    find_opts["syntax"] = "kustomize"
    kube.find_path(find_opts)
end

return M
