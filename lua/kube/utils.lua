local yaml = require('lyaml')
-- Set the default notify function to nvim.notify
vim.notify = require("notify")

local M = {}

local function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    -- Check if there is leading whitespace and add that to the
    -- string split table
    local whitespace = string.match(inputstr, "^%s+")
    if whitespace ~= nil then
        table.insert(t, whitespace)
    end
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function Recursive_print(table)
    for key, value in pairs(table) do
        if type(value) == "table" then
            print("table key: " .. key)
            print("table value: ", value)
            Recursive_print(value)
        else
            local word = string.match(value, "%w+")
            if word == nil then
                print("key: " .. key .. ', ' .. "value:" .. value)
            else
                print("key: " .. key .. ', ' .. "value:" .. value)
            end
        end
    end
end

-- DOCUMENTATION

-- ERROR handling and edge cases
-- How to handle running the search function on a line that contains no yaml?
-- Case 1: document separators
--  "---" or "..."




-- | "TLMKV"
-- | recursive_find_value()
-- |Top level map with key value
-- | apiVersion: networking.k8s.io/v1

-- | "TLK"
-- | recursive_find_key()
-- | 7 Top level key
-- |metadata:

-- | "IOK"
-- | recursive_find_key()
-- |Indented object key
-- |  annotations:

-- | "IMKV"
-- | recursive_find_value()
-- |Indented map with key value
-- |    cert-manager.io/cluster-issuer: acme # This will attempt to automatically generate a cert.

-- | "AKV"
-- | recursive_find_value()
-- |Array with key value
-- |    - host: uxguide-temp.k8s.epic.com # What about this

-- | "AOK"
-- | recursive_find_key()
-- |Array object key
-- |       - backend: # some stuff

-- | "AVO"
-- | recursive_find_value()
-- |Array value only
-- |        - uxguide-temp.k8s.epic.com

-- res table schema
-- res["table_type"] = 1 of the 7 search types listed above
-- res["search_str"] = the search string returned from the set_search_string function
-- res["original_key"] = the key name that was replaced with the needle
--      This is useful for object keys since the object key itself gets replaced
--      when setting the needle and needs to be reiserted into the path
--      after the path is returned from the search function

local function build_search_opts(str_input_table, needle)
    local res = {}
    res["table_type"] = ""
    local search_str = ""
    if str_input_table[1] == nil then
        return
    end
    -- TODO fix this comment
    -- case 1: top level key
    if (string.match(str_input_table[1], ":$") ~= nil) then
        if (str_input_table[2] ~= nil) and (str_input_table[2] ~= "#") then
            search_str = str_input_table[1] .. " " .. needle
            res["table_type"] = "TLMKV"
            res["search_str"] = search_str
            return res
        else
            search_str = needle .. ":"
            res["original_key"] = string.match(str_input_table[1], "%w+")
            res["table_type"] = "TLK"
            res["search_str"] = search_str
            return res
        end
    end

    -- We now know there is just whitespace in the first table index
    -- If true the first value in the string table is leading whitespace
    if (string.match(str_input_table[1], "%S") == nil) then
        -- If true, the second value in the string is a key value
        if (string.match(str_input_table[2], ":$") ~= nil) then
            -- matches "   key:"
            if str_input_table[3] == nil then
                search_str = search_str .. str_input_table[1] .. needle .. ":"
                res["original_key"] = string.match(str_input_table[2], "%w+")
                res["table_type"] = "IOK"
                res["search_str"] = search_str
                return res
            end
            if (str_input_table[3] ~= nil) and (str_input_table[3] == "#") then
                search_str = search_str .. str_input_table[1] .. needle .. ":"
                res["original_key"] = string.match(str_input_table[2], "%w+")
                res["table_type"] = "IOK"
                res["search_str"] = search_str
                return res
            end
            if (str_input_table[3] ~= nil) and (str_input_table[3] ~= "#") then
                -- search_str = search_str .. str_input_table[1] .. str_input_table[2] .. " AXOEIEO5346322"
                search_str = search_str .. str_input_table[1] .. str_input_table[2] .. " " .. needle
                res["table_type"] = "IMKV"
                res["search_str"] = search_str
                return res
            end
        end
    end

    for key, value in pairs(str_input_table) do
        if (string.match(value, "%S") == nil) then
            search_str = search_str .. value

            -- This will match array objects
        elseif (value == "-") and (string.match(str_input_table[key + 1], ":$") == nil) then
            -- search_str = search_str .. value .. " AXOEIEO5346322"
            search_str = search_str .. value .. " " .. needle
            res["table_type"] = "AVO"
            res["search_str"] = search_str
            return res
            -- This will match "   - key:"
        elseif (value == "-") and (string.match(str_input_table[key + 1], ":$") ~= nil) then
            if (str_input_table[key + 2] ~= nil) and (str_input_table[key + 2] == "#") then
                print("made it into elseif 2 if 1")
                -- search_str = search_str .. "- AXOEIEO5346322:"
                search_str = search_str .. "- " .. needle .. ":"
                res["original_key"] = string.match(str_input_table[key + 1], "%w+")
                res["table_type"] = "AOK"
                res["search_str"] = search_str
                return res
            end

            -- This will match "    - key:"
            if (str_input_table[key + 2] == nil) then
                -- search_str = search_str .. "- AXOEIEO5346322:"
                search_str = search_str .. "- " .. needle .. ":"
                res["original_key"] = string.match(str_input_table[key + 1], "%w+")
                res["table_type"] = "AOK"
                res["search_str"] = search_str
                return res
            end

            -- if the next value is not a comment then it will match "   - key: value"
            if (str_input_table[key + 2] ~= nil) and (str_input_table[key + 2] ~= "#") then
                -- search_str = search_str .. "- " .. str_input_table[key+1] .. " AXOEIEO5346322"
                search_str = search_str .. "- " .. str_input_table[key + 1] .. " " .. needle
                res["table_type"] = "AKV"
                res["search_str"] = search_str
                return res
            end
        end
    end
end

local function recursive_find_value(t, value_to_find, paths, current_path)
    if paths == nil then
        paths = {}
    end
    if current_path == nil then
        current_path = {}
    end

    -- print("current_path:", current_path)
    for key, value in pairs(t) do
        -- print("key:", key)
        -- print("value", value)
        if (type(value) ~= "table") and (value == value_to_find) then
            -- print("found the value, adding current path to paths and returning")
            -- table.insert(current_path,key)
            -- table.insert(paths,current_path)
            local res = {}
            table.insert(res, key)
            return res
        end

        if type(value) == "table" then
            -- table.insert(current_path,key)
            local result = recursive_find_value(value, value_to_find, paths, current_path)
            local next = next
            if next(result) ~= nil then
                local path = {}
                table.insert(path, key .. ">" .. result[1])
                return path
            end
        end
    end
    return {}
end

local function recursive_find_key(t, key_to_find, paths, current_path)
    if paths == nil then
        paths = {}
    end
    if current_path == nil then
        current_path = {}
    end

    -- print("current_path:", current_path)
    for key, value in pairs(t) do
        -- print("key:", key)
        -- print("value", value)
        if (key == key_to_find) then
            local path = {}
            table.insert(path, key)
            return path
        end

        if type(value) == "table" then
            local result = recursive_find_key(value, key_to_find, paths, current_path)
            local next = next
            if next(result) ~= nil then
                local path = {}
                table.insert(path, key .. ">" .. result[1])
                return path
            end
        end
    end
    return {}
end

local function string_reindex(input_str, reindex_syntax)
    local string_table = mysplit(input_str, ">")

    if reindex_syntax == "yq" then
        for key, value in ipairs(string_table) do
            local number = tonumber(value)
            if number ~= nil then
                string_table[key] = "[" .. (number - 1) .. "]"
            end
        end

        for key, value in ipairs(string_table) do
            if string.match(value, "/") ~= nil then
                string_table[key] = '"' .. value .. '"'
            end
        end
    end

    if reindex_syntax == "kustomize" then
        for key, value in ipairs(string_table) do
            local number = tonumber(value)
            if number ~= nil then
                string_table[key] = (number - 1)
            end
        end

        for key, value in ipairs(string_table) do
            if string.match(value, "/") ~= nil then
                string_table[key] = string.gsub(string_table[key], "/", "~1")
            end
        end
    end

    local new_reindexed_str = ""

    if reindex_syntax == "yq" then
        for _, value in ipairs(string_table) do
            new_reindexed_str = new_reindexed_str .. "." .. value
        end
    end
    if reindex_syntax == "kustomize" then
        for _, value in ipairs(string_table) do
            new_reindexed_str = new_reindexed_str .. "/" .. value
        end
    end

    return new_reindexed_str
end


-- The Find_path() function will find the path to a key in a yaml document
-- The function will copy the path to the global clipboard in 2 syntaxes:
--      yq syntax
--      kustomize path patch syntax
-- The keypress that executes this function will pass to the Find_path()
-- function a option that will determine the desired path syntax you want
-- to copy
-- Find_path(find_opts) takes in input table that will customize the behavior
-- of the Find_path() function
--
-- find_opts{} will have a value find_opts["syntax"] that can be:
--      "yq"
--      "kustomize"
-- Find_path() will copy the search string to your global buffer and
-- use notify to signal to the user what path it has copied to the clipboard
function M.find_path(find_opts)
    -- Grab the current line the cursor is on when the function is executed
    local cur_line = vim.api.nvim_get_current_line()
    -- Tokenize the current line into a table
    local split_cur_line = mysplit(cur_line)
    -- Create a needle to insert into the haystack
    -- This needle must be:
    -- a base64 string containing only AlphaNumeric characters (no symbols)
    -- 8-16 chars long
    local needle = "8YDxcEYQyu0UKU4"
    -- build the search opts. Returns a table
    local search_opts = build_search_opts(split_cur_line, needle)
    if search_opts == nil then
        print("No yaml path found...")
        return
    end
    -- set the search string in the buffer
    vim.api.nvim_set_current_line(search_opts["search_str"])
    -- read the yaml doc into a var from the current buffer
    local current_buf_content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
    local current_buf_string = table.concat(current_buf_content, "\n")
    local yaml_data = yaml.load(current_buf_string)
    -- restore the current line after loading in the buffer with the
    -- inserted needle
    -- This should restore the file to the state before the function was called
    vim.api.nvim_set_current_line(cur_line)
    -- Based on the string type pick a search function
    -- Search function will return the build path
    local path_table = {}
    if search_opts["table_type"] == "TLMKV" then
        path_table = recursive_find_value(yaml_data, needle)
    end
    if search_opts["table_type"] == "TLK" then
        path_table = recursive_find_key(yaml_data, needle)
        path_table[1] = string.gsub(path_table[1], needle, search_opts["original_key"])
    end
    if search_opts["table_type"] == "IOK" then
        path_table = recursive_find_key(yaml_data, needle)
        path_table[1] = string.gsub(path_table[1], needle, search_opts["original_key"])
    end
    if search_opts["table_type"] == "IMKV" then
        path_table = recursive_find_value(yaml_data, needle)
    end
    if search_opts["table_type"] == "AKV" then
        path_table = recursive_find_value(yaml_data, needle)
    end
    if search_opts["table_type"] == "AOK" then
        path_table = recursive_find_key(yaml_data, needle)
        path_table[1] = string.gsub(path_table[1], needle, search_opts["original_key"])
    end
    if search_opts["table_type"] == "AVO" then
        path_table = recursive_find_value(yaml_data, needle)
    end

    -- reindex the path returned from the find function
    -- We need to reindex the path to account for lua starting indexes at 1
    -- Pass the syntax you want to format the path into. Can be:
    --  "yq" or "kustomize"
    path_table[1] = string_reindex(path_table[1], find_opts["syntax"])

    -- Copy the path to the global clipboard
    vim.fn.setreg("+Y", path_table[1])
    vim.notify(path_table[1] .. ' copied to clipboard...', vim.log.levels.INFO, { stages = "fade" })

    -- for now just print the found path to the console
    print(path_table[1])
end

return M
