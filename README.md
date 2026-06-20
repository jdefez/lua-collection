# lua-collection

A Lua utility library for Neovim providing a fluent, chainable API for working with tables.

## Installation

Requires Neovim 0.11+ (uses the built-in `vim.pack` API).

```lua
vim.pack.add("https://github.com/jdefez/lua-collection")
```

## Usage

```lua
local collect = require("collection").collect
```

### Creating a collection

```lua
-- from an array
local animals = collect({ "dog", "cat", "mouse" })

-- from an associative table
local config = collect({ host = "localhost", port = 8080 })

-- empty collection
local empty = collect()
```

### Adding and retrieving items

```lua
-- push one or more items onto an array collection
animals:push("bird", "fish")

-- set a key on an associative collection
config:put("debug", true)

-- get a value by key
config:get("host")  -- "localhost"

-- first and last items
animals:first()  -- "dog"
animals:last()   -- "mouse"
```

### Removing items

```lua
animals:shift()  -- removes and returns "dog" (first)
animals:pop()    -- removes and returns "mouse" (last)
```

### Iterating

```lua
-- each (returns self for chaining)
animals:each(function(value, key)
    print(key, value)
end)

-- filter (returns a new collection)
local dogs = animals:filter(function(value)
    return value == "dog"
end)
```

### Merging

```lua
local more = collect({ "bird", "fish" })
animals:merge(more)
```

### Keys and values

```lua
animals:keys()    -- { 1, 2, 3, ... }
animals:values()  -- { "dog", "cat", ... }

-- works on associative tables too
config:keys()     -- { "host", "port", "debug" }
config:values()   -- { "localhost", 8080, true }
```

### Querying

```lua
animals:count()       -- number of items
animals:is_empty()    -- true / false
animals:is_not_empty() -- true / false

-- contains a value
animals:contains("dog")  -- true

-- contains with a predicate
animals:contains(function(value)
    return value:sub(1, 1) == "d"
end)  -- true

-- contains a key-value pair
config:contains("host", "localhost")  -- true

-- some / every
animals:some(function(v) return v == "cat" end)   -- true if any match
animals:every(function(v) return #v > 2 end)      -- true if all match
```

### Set operations

```lua
local a = collect({ "dog", "cat", "moose" })

-- values in a not present in the given table/collection
a:diff({ "cat", "moose" })      -- Collection{ "dog" }

-- values in a that are also in the given table/collection
a:intersect({ "cat", "moose" }) -- Collection{ "cat", "moose" }
```

### Chaining

Most methods return `self`, so calls can be chained:

```lua
collect({ "dog", "cat", "mouse", "bird" })
    :filter(function(v) return #v == 3 end)
    :each(function(v) print(v) end)
-- dog
-- cat
```

## Running the tests

Tests use [busted](https://lunarmodules.github.io/busted/). Install it with LuaRocks:

```bash
luarocks install busted --local
```

Then run:

```bash
make test
# or directly:
busted --helper tests/setup.lua tests/test_collection.spec.lua
```
