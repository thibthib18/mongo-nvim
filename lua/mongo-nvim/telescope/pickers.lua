local actions = require "telescope.actions"
local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local action_state = require "telescope.actions.state"
local conf = require "telescope.config".values
local action_set = require "telescope.actions.set"
local mongo_previewers = require "mongo-nvim.telescope.previewer"
local utils = require "mongo-nvim.telescope.utils"
local mongo = require "mongo-nvim.mongo"
local mongo_buffer = require "mongo-nvim.buffer"

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

function M.document_picker(dbName, collectionName)
    local documents = mongo.list_documents(dbName, collectionName)
    local picker_opts = {}
    picker_opts.preview_title = "Value"
    picker_opts.prompt_title = ""
    picker_opts.results_title = "Documents"
    pickers.new(
        picker_opts,
        {
            finder = finders.new_table {
                results = utils.gen_document_entries(dbName, collectionName, documents),
                entry_maker = utils.gen_from_document()
            },
            sorter = conf.generic_sorter(picker_opts),
            previewer = mongo_previewers.document_preview(dbName, collectionName),
            attach_mappings = function(_, map)
                action_set.select:replace(
                    function(prompt_bufnr, type)
                        actions.close(prompt_bufnr)
                        local entry = action_state.get_selected_entry()
                        local query = mongo.make_query("_id", entry.id)
                        local bson_document = mongo.find_bson_document(dbName, collectionName, query)
                        mongo_buffer.create(dbName, collectionName, bson_document)
                    end
                )
                -- mapping to delete document
                local function delete_selected_document(prompt_bufnr)
                    local documentId = action_state.get_selected_entry().id
                    print("Deleting document " .. documentId .. " ...")
                    local success = mongo.delete_document(dbName, collectionName, documentId)
                    if not success then
                        return
                    end
                    action_state.get_current_picker(prompt_bufnr):delete_selection(
                        function()
                        end
                    )
                end
                if MONGO_CONFIG.delete_document_mapping ~= nil then
                    map("n", MONGO_CONFIG.delete_document_mapping, delete_selected_document)
                    map("i", MONGO_CONFIG.delete_document_mapping, delete_selected_document)
                end
                return true
            end
        }
    ):find()
end

return M
