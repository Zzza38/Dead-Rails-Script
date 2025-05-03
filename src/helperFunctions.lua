-- Clone a table (shallow copy)
function clone(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = v
    end
    return copy
end

-- Deep clone (for nested tables)
function deepClone(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = deepClone(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Get keys from a table
function keys(tbl)
    local result = {}
    for k, _ in pairs(tbl) do
        table.insert(result, k)
    end
    return result
end

-- Get values from a table
function values(tbl)
    local result = {}
    for _, v in pairs(tbl) do
        table.insert(result, v)
    end
    return result
end

-- Check if a table contains a value
function includes(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then return true end
    end
    return false
end

-- Get length of a table (for dictionary-style)
function length(tbl)
    local count = 0
    for _, _ in pairs(tbl) do count += 1 end
    return count
end

-- Merge two tables (overwrites keys)
function merge(tbl1, tbl2)
    local result = clone(tbl1)
    for k, v in pairs(tbl2) do
        result[k] = v
    end
    return result
end

-- Map a table like JS Array.map
function map(tbl, func)
    local result = {}
    for i, v in pairs(tbl) do
        result[i] = func(v, i)
    end
    return result
end

-- Filter a table like JS Array.filter
function filter(tbl, func)
    local result = {}
    for i, v in pairs(tbl) do
        if func(v, i) then
            result[i] = v
        end
    end
    return result
end

-- Convert table to array (no keys, just values in order)
function toArray(tbl)
    local result = {}
    for _, v in pairs(tbl) do
        table.insert(result, v)
    end
    return result
end

-- Pretty print a table (basic)
function dump(tbl, indent)
    indent = indent or 0
    for k, v in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. tostring(k) .. ": "
        if type(v) == "table" then
            print(formatting)
            dump(v, indent + 1)
        else
            print(formatting .. tostring(v))
        end
    end
end
