local utils = require("kube.utils")

local M = {}

function M.get_yq_path()
    local find_opts = {}
    find_opts["syntax"] = "yq"
    utils.find_path(find_opts)
end

function M.get_kustomize_path()
    local find_opts = {}
    find_opts["syntax"] = "kustomize"
    utils.find_path(find_opts)
end

return M
