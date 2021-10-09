local entry_display = require "telescope.pickers.entry_display"

local M = {}

function M.gen_from_name()
    local make_display = function(entry)
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
