local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local action_state = require "telescope.actions.state"
local conf = require "telescope.config".values
local action_set = require "telescope.actions.set"
local mongo_previewers = require "mongo-nvim.telescope.previewer"
local utils = require "mongo-nvim.telescope.utils"
local mongo = require "mongo-nvim.mongo"

local M = {}

function M.database_picker()
    local dbs = mongo.list_databases()
    local picker_opts = {}
    picker_opts.preview_title = "Collections"
    picker_opts.prompt_title = ""
    picker_opts.results_title = "Databases"
    pickers.new(
        picker_opts,
        {
            finder = finders.new_table {
                results = utils.gen_entries(dbs),
                entry_maker = utils.gen_from_name()
            },
            sorter = conf.generic_sorter(picker_opts),
            previewer = mongo_previewers.db_preview(),
            attach_mappings = function(_, map)
                action_set.select:replace(
                    function(prompt_bufnr, type)
                        local selection = action_state.get_selected_entry()
                        M.collection_picker(selection.name)
                    end
                )
                return true
            end
        }
    ):find()
end

function M.collection_picker(db)
    local collectionNames = mongo.list_collections(db)
    local picker_opts = {}
    picker_opts.preview_title = "Items"
    picker_opts.prompt_title = ""
    picker_opts.results_title = "Collections"
    pickers.new(
        picker_opts,
        {
            finder = finders.new_table {
                results = utils.gen_entries(collectionNames),
                entry_maker = utils.gen_from_name()
            },
            sorter = conf.generic_sorter(picker_opts),
            previewer = mongo_previewers.collection_preview(db),
            attach_mappings = function(_, map)
                action_set.select:replace(
                    function(prompt_bufnr, type)
                        local selection = action_state.get_selected_entry()
                        M.document_picker(db, selection.name)
                    end
                )
                return true
            end
        }
    ):find()
end

function M.document_picker(db, collectionName)
    local documents = mongo.list_documents_by_key(db, collectionName, MONGO_CONFIG.list_document_key)
    local picker_opts = {}
    picker_opts.preview_title = "Value"
    picker_opts.prompt_title = ""
    picker_opts.results_title = "Documents"
    pickers.new(
        picker_opts,
        {
            finder = finders.new_table {
                results = utils.gen_entries(documents),
                entry_maker = utils.gen_from_name()
            },
            sorter = conf.generic_sorter(picker_opts),
            previewer = mongo_previewers.document_preview(db, collectionName),
            attach_mappings = function(_, map)
                action_set.select:replace(
                    function(prompt_bufnr, type)
                        print("ok")
                    end
                )
                --map("i", "<c-b>", open())
                return true
            end
        }
    ):find()
end

return M
