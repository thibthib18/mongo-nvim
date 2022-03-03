local previewers = require "telescope.previewers"
local mongo = require "mongo-nvim.mongo"
local utils = require "mongo-nvim.telescope.utils"

local M = {}

function M.document_preview(dbName, collectionName)
    return previewers.new_buffer_previewer {
        get_buffer_by_name = function(_, entry)
            return entry.name
        end,
        define_preview = function(self, entry)
            local bufnr = self.state.bufnr
            if self.state.bufname ~= entry.name or vim.api.nvim_buf_line_count(bufnr) == 1 then
                local query = mongo.make_query("_id", entry.id)
                local bson_document = mongo.find_bson_document(dbName, collectionName, query)
                local document_lines = utils.splitlines(vim.inspect(bson_document:value()))
                local winnr = vim.fn.bufwinnr(bufnr)
                local winid = vim.fn.win_getid(winnr)
                vim.api.nvim_win_set_option(winid, "wrap", true)
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, document_lines)
            end
        end
    }
end

function M.collection_preview(dbName)
    return previewers.new_buffer_previewer {
        get_buffer_by_name = function(_, entry)
            return entry.name
        end,
        define_preview = function(self, entry)
            local bufnr = self.state.bufnr
            if self.state.bufname ~= entry.name or vim.api.nvim_buf_line_count(bufnr) == 1 then
                local collectionName = entry.name
                local documents = mongo.list_documents(dbName, collectionName)
                local document_list = {}
                for _, document in ipairs(documents) do
                    local display_value = utils.get_display_value(dbName, collectionName, document)
                    table.insert(document_list, tostring(display_value))
                end
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, document_list)
            end
        end
    }
end

function M.db_preview()
    return previewers.new_buffer_previewer {
        get_buffer_by_name = function(_, entry)
            return entry.name
        end,
        define_preview = function(self, entry)
            local bufnr = self.state.bufnr
            if self.state.bufname ~= entry.name or vim.api.nvim_buf_line_count(bufnr) == 1 then
                local collectionNames = mongo.list_collections(entry.name)
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, collectionNames)
            end
        end
    }
end

return M
