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

function M.list_documents_by_key(dbName, collectionName, key)
    local client = mongo.Client(MONGO_CONFIG.connection_string)
    local db = client:getDatabase(dbName)
    local collection = db:getCollection(collectionName)
    local cursor = collection:find({})
    local documents = {}
    for value in cursor:iterator() do
        table.insert(documents, tostring(value[key]))
    end
    return documents
end

function M.make_query(key, value)
    -- "_id" cannot be handled as string
    if key == "_id" then
        local bsonid = mongo.ObjectID(value)
        return mongo.BSON {_id = bsonid}
    end
    return '{ "' .. key .. '": "' .. value .. '"}'
end

function M.find_document(dbName, collectionName, query)
    local client = mongo.Client(MONGO_CONFIG.connection_string)
    local db = client:getDatabase(dbName)
    local collection = db:getCollection(collectionName)
    local document = collection:findOne(query):value()
    return document
end

return M
