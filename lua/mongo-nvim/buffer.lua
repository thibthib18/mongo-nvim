local utils = require "mongo-nvim.telescope.utils"
local mongo = require "mongo-nvim.mongo"
local M = {}

_G.mongo_nvim_buffers = {}

function M.create(dbName, collectionName, bson_document)
    local bufnr = vim.api.nvim_create_buf(true, true)
    M.render(bufnr, bson_document)
    local this = {
        bufnr = bufnr,
        dbName = dbName,
        collectionName = collectionName,
        document = bson_document,
        id = tostring(bson_document:value()._id)
    }
    mongo_nvim_buffers[this.bufnr] = this

    return this
end

function M.render(bufnr, bson_document)
    local str_data = tostring(bson_document)
    local json_data = vim.fn.json_decode(str_data)
    local document_lines = utils.splitlines(vim.inspect(json_data))

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, document_lines)
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_option(bufnr, "syntax", "lua")
    vim.api.nvim_buf_set_option(bufnr, "buftype", "acwrite")
    vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
    vim.api.nvim_buf_set_option(bufnr, "modified", false)
    vim.cmd(string.format("file mongo_nvim://%s", tostring(bson_document:value()._id)))
end

function M.save()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local str_data = table.concat(lines, "\n")
    -- load the data into a table
    -- likely quite hacky, make the str data a lua chunk and load it
    local chunk = "return " .. str_data
    local get_data, err = load(chunk)
    if not get_data then
        print("Failed to load data as valid Lua table")
        print(err)
    end
    local updated_document = get_data()
    local buffer = mongo_nvim_buffers[bufnr]
    mongo.update_document(buffer.dbName, buffer.collectionName, buffer.id, updated_document)
    vim.api.nvim_buf_set_option(bufnr, "modified", false)
end

return M
