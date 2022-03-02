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

function M.find_bson_document(dbName, collectionName, query)
    local client = mongo.Client(MONGO_CONFIG.connection_string)
    local db = client:getDatabase(dbName)
    local collection = db:getCollection(collectionName)
    local document = collection:findOne(query)
    return document
end

function M.find_document(dbName, collectionName, query)
    local client = mongo.Client(MONGO_CONFIG.connection_string)
    local db = client:getDatabase(dbName)
    local collection = db:getCollection(collectionName)
    local document = collection:findOne(query):value()
    return document
end

function M.update_document(dbName, collectionName, id, updated_document)
    local client = mongo.Client(MONGO_CONFIG.connection_string)
    local db = client:getDatabase(dbName)
    local collection = db:getCollection(collectionName)
    local query = M.make_query("_id", id)
    updated_document["_id"] = nil

    local json_data = vim.fn.json_encode(updated_document)
    local bson_doc = mongo.BSON(json_data)
    local update = '{ "$set" : ' .. json_data .. "}"

    local success, err = collection:updateOne(query, update)
    if not success then
        print(string.format("Failed to update document ID: %s", id))
        print(err)
        return
    end
    print("Successfully updated document ID " .. id)
end

return M
