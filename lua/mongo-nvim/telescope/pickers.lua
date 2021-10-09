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
    picker_opts.preview_title = "Info"
    picker_opts.prompt_title = ""
    picker_opts.results_title = "List"
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
    picker_opts.preview_title = "Info"
    picker_opts.prompt_title = ""
    picker_opts.results_title = "List"
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
                        M.item_picker(db, selection.name)
                    end
                )
                return true
            end
        }
    ):find()
end

function M.item_picker(db, collectionName)
    local items = mongo.list_items_by_key(db, collectionName, "setting")
    local picker_opts = {}
    picker_opts.preview_title = "Info"
    picker_opts.prompt_title = ""
    picker_opts.results_title = "List"
    pickers.new(
        picker_opts,
        {
            finder = finders.new_table {
                results = utils.gen_entries(items),
                entry_maker = utils.gen_from_name()
            },
            sorter = conf.generic_sorter(picker_opts),
            previewer = mongo_previewers.item_preview(db, collectionName),
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
