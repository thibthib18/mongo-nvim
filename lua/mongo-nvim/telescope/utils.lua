local entry_display = require "telescope.pickers.entry_display"

local M = {}

function M.get_display_value(dbName, collectionName, document)
    local value = tostring(document._id)
    if type(MONGO_CONFIG.list_document_key) == "string" then
        return tostring(document[MONGO_CONFIG.list_document_key])
    end
    local display_key = MONGO_CONFIG.list_document_key[dbName][collectionName]
    if type(display_key) == "string" then
        value = document[display_key]
    end
    if type(display_key) == "function" then
        value = display_key(document)
    end
    return value
end

local function make_display(entry)
    if not entry then
        return nil
    end

    local columns = {
        {entry.name}
    }

    local displayer =
        entry_display.create {
        separator = " ",
        items = {
            {remaining = true}
        }
    }

    return displayer(columns)
end

function M.gen_from_name()
    return function(entry)
        if not entry or vim.tbl_isempty(entry) then
            return nil
        end

        return {
            value = 1,
            ordinal = entry.name,
            display = make_display,
            name = entry.name
        }
    end
end

function M.gen_from_document()
    return function(entry)
        if not entry or vim.tbl_isempty(entry) then
            return nil
        end

        return {
            value = 1,
            ordinal = entry.name,
            display = make_display,
            name = entry.name,
            id = entry.id
        }
    end
end

function M.gen_document_entries(dbName, collectionName, documents)
    local entries = {}
    for _, document in ipairs(documents) do
        local id = tostring(document._id)
        local display_value = M.get_display_value(dbName, collectionName, document)
        table.insert(entries, {name = display_value, id = id})
    end
    return entries
end

function M.gen_entries(results)
    local entries = {}
    for _, name in ipairs(results) do
        table.insert(entries, {name = name})
    end
    return entries
end

function M.splitlines(s)
    local function splitlines_it(s)
        if s:sub(-1) ~= "\n" then
            s = s .. "\n"
        end
        return s:gmatch("(.-)\n")
    end

    local lines = {}
    for line in splitlines_it(s) do
        table.insert(lines, line)
    end
    return lines
end
return M
