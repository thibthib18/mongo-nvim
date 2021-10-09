local mongo = require "mongo"

local M = {}

function M.list_databases()
    local client = mongo.Client(MONGO_CONFIG.connection_string)
    local dbs = client:getDatabaseNames()
    return dbs
end

function M.list_collections(dbName)
    local client = mongo.Client(MONGO_CONFIG.connection_string)
    local db = client:getDatabase(dbName)
    local collectionNames = db:getCollectionNames()
    return collectionNames
end

function M.list_items_by_key(dbName, collectionName, key)
    local client = mongo.Client(MONGO_CONFIG.connection_string)
    local db = client:getDatabase(dbName)
    local collection = db:getCollection(collectionName)
    local cursor = collection:find({})
    local items = {}
    for value in cursor:iterator() do
        table.insert(items, value[key])
    end
    return items
end

function M.find_item(dbName, collectionName, selector)
    local client = mongo.Client(MONGO_CONFIG.connection_string)
    local db = client:getDatabase(dbName)
    local collection = db:getCollection(collectionName)
    local item = collection:findOne(selector):value()
    return item
end

return M
