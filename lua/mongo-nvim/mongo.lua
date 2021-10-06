local M = {}

local function call_mongo_script(script)
    local command = "mongo " .. MONGO_CONFIG.connection_string .. " --quiet" .. ' --eval "' .. script .. '"'
    return vim.fn.system(command)
end

function M.get_databases()
    local list_databases = "db.adminCommand('listDatabases')"
    local function parse_databases(databases_json)
        local databases = vim.fn.json_decode()
    end
    local databases_json = call_mongo_script(list_databases)
    return parse_databases(databases_json)
end

return M
