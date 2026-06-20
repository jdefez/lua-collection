local Collection = {}
Collection.__index = Collection

---@class Collection
function Collection:new(tbl)
    local obj = setmetatable({}, self)
    obj.table = tbl or {}
    return obj
end

Collection.collect = function(tbl)
    return Collection:new(tbl)
end

function Collection:isArray(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

---@return self
function Collection:push(...)
    local items = { ... }
    for _, item in ipairs(items) do
        table.insert(self.table, item)
    end
    return self
end

---@param key string|number
---@param value any
---@return self
function Collection:put(key, value)
    self.table[key] = value
    return self
end

---@param key string|number
---@return any
function Collection:get(key)
    return self.table[key]
end

---@return table
function Collection:keys()
    local keys = {}
    for key, _ in pairs(self.table) do
        table.insert(keys, key)
    end
    return keys
end

---@return table
function Collection:values()
    local values = {}
    if self:isArray(self.table) then
        for _, value in ipairs(self.table) do
            table.insert(values, value)
        end
        return values
    end

    for _, value in pairs(self.table) do
        table.insert(values, value)
    end

    return values
end

---@param collection Collection
---@return self
function Collection:merge(collection)
    for key, value in pairs(collection.table) do
        if type(key) == 'number' then
            self:push(value)
        else
            self:put(key, value)
        end
    end
    return self
end

---@return any
function Collection:shift()
    return table.remove(self.table, 1)
end

---@return any
function Collection:pop()
    return table.remove(self.table, #self.table)
end

---@return any
function Collection:first()
    return self.table[1]
end

---@return any
function Collection:last()
    return self.table[#self.table]
end

---@param fn function(value: any, key: any)
---@return self
function Collection:each(fn)
    for key, value in ipairs(self.table) do
        fn(value, key)
    end
    return self
end

---@param fn function(value: any, key: any)
---@return self
function Collection:filter(fn)
    local new_collection = Collection:new()
    for key, value in ipairs(self.table) do
        if fn(value, key) then
            new_collection:push(value)
        end
    end
    return new_collection
end

function Collection:count()
    if self:isArray(self.table) then
        return #self.table
    end

    return Collection:new(self:values()):count()
end

function Collection:is_empty()
    return self:count() == 0
end

function Collection:is_not_empty()
    return self:count() > 0
end

---@param key string|function
---@param value any
---@return boolean
function Collection:contains(key, value)
    if value == nil then
        for k, v in pairs(self.table) do
            if type(key) == 'function' and key(v, k) then
                return true
            elseif v == key then
                return true
            end
        end
    elseif (type(key) == 'string' and value ~= nil) then
        return self:get(key) == value
    end
    return false
end

---@param fn function(value: any, key: any)
---@return boolean
function Collection:some(fn)
    for key, value in ipairs(self.table) do
        if fn(value, key) then
            return true
        end
    end
    return false
end

---@param fn function(value: any, key: any)
---@return boolean
function Collection:every(fn)
    for key, value in ipairs(self.table) do
        if not fn(value, key) then
            return false
        end
    end
    return true
end

---@param collection Collection | table
---@return Collection
function Collection:diff(collection)
    local found = Collection:new()

    if type(collection) == 'table' then
        collection = Collection:new(collection)
    end

    self:each(function(value)
        if not collection:contains(value) then
            found:push(value)
        end
    end)

    return found
end

---@param collection Collection | table
---@return Collection
function Collection:intersect(collection)
    local found = Collection:new()

    if type(collection) == 'table' then
        collection = Collection:new(collection)
    end

    self:each(function(value)
        if collection:contains(value) then
            found:push(value)
        end
    end)

    return found
end

return Collection
