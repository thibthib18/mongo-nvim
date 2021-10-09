local previewers = require "telescope.previewers"
local mongo = require "mongo-nvim.mongo"
local utils = require "mongo-nvim.telescope.utils"

local M = {}

function M.item_preview(dbName, collectionName)
    return previewers.new_buffer_previewer {
        get_buffer_by_name = function(_, entry)
            return entry.name
        end,
        define_preview = function(self, entry)
            local bufnr = self.state.bufnr
            if self.state.bufname ~= entry.name or vim.api.nvim_buf_line_count(bufnr) == 1 then
                local selector = '{ "' .. MONGO_CONFIG.list_item_key .. '": "' .. entry.name .. '"}'
                local item = mongo.find_item(dbName, collectionName, selector)
                local item_lines = utils.splitlines(vim.inspect(item.value))
                local winnr = vim.fn.bufwinnr(bufnr)
                local winid = vim.fn.win_getid(winnr)
                vim.api.nvim_win_set_option(winid, "wrap", true)
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, item_lines)
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
                local items = mongo.list_items_by_key(dbName, entry.name, MONGO_CONFIG.list_item_key)
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, items)
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
