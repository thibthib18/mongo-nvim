local M = {}

MONGO_CONFIG = {
    connection_string = "mongodb://127.0.0.1:27017",
    list_item_key = "setting"
}

function M.setup(config)
    for key, value in pairs(config) do
        if value ~= nil then
            MONGO_CONFIG[key] = value
        end
    end
end

return M
