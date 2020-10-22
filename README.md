# au

Array Utils (`au`) are a collection of various functional-esque Lua functions for interacting with collections.

Many of these behave `immutably` which isn't the best in Lua. Using functions that return tables will increase your memory usage, and make the GC work hard. Make sure not to use these in too many loops.

If using in LuaJIT, then watch out for those functions that state that they use NYI functionality, such as `pairs` or `next`.

Getting going is real simple. Put this file into your project, then require it:

```lua
local au = require "path.to.au"
```

## API

The best way to learn how to use this is to take a look at all the various functions that `au` exposes.

### Helpers

This section describes the helper functions that `au` exposes:

#### some(x)

Returns `true` if `x` is not `nil`, otherwise returns false.

```lua
local notNil = 5
local totallyNil = nil

au.some(notNil) -- returns true
au.some(totallyNil) -- returns false
```

#### none(x)

Returns `true` if `x` is `nil`, otherwise returns `false`

```lua
local notNil = 5
local totallyNil = nil

au.some(notNil) -- returns false
au.some(totallyNil) -- returns true
```

#### identity(x)

Returns the identity of `x` (smart way of saying it just returns `x`)

```lua
5 == au.identity(5) --evaluates to true
```

#### inc(x) and dec(x)

Increments on Decrements x.

```lua
au.inc(1) -- returns 2
au.dec(1) -- returns 0
```

#### add(a, b) and sub(a, b)

Same as `a + b` and `a - b`.

```lua
au.add(1, 1) -- returns 2
au.sub(1, 1) -- returns 0
```

#### equals(a, b)

If you provide `equals` with an `a` and `b` value, it behaves like `a == b`.

```lua
au.equals(1, 1) -- returns true
```

However, if you _don't_ provide `b`, then `equals` returns a function that takes
one argument, `b` and when called will perform `a == b`:

```lua
local five = 5
local equalToFive = au.equals(5)
equalToFive(five) -- returns true
```

#### constantly(x)

Returns a function that takes any number of args, and will always return `x`

```lua
local alwaysFive = au.constantly(5)
alwaysFive() -- returns 5
alwaysFive(4) -- returns 5
alwaysFive("variable", { arg = "uments"}) -- returns 5
```

#### complement(fn)

Returns the complement of the provided function. For example `au.none` is the complement to `au.some`

```lua
local none = au.complement(au.some)
none(nil) -- returns true
```

### Table Utilities

The following are utilities specifically for tables.

#### get(tbl, k, default)

Retrieves the value for key `k` in table `tbl`. If the value is `nil`, then returns optionally provided `default`.

```lua
local tbl = {a = 1, b = 2}
au.get(tbl, "a") -- returns 1
au.get(tbl, "b", 3) -- returns 2
au.get(tbl, "c", 3) -- returns 3
```

#### keys(tbl)

Returns all the keys of the provided table `tbl`. Under the hood, this uses `next` which isn't implemented in LuaJIT,
so use with caution.

```lua
local tbl = { a = 1, b = 2, c = 3}
au.keys(tbl) -- returns { "a", "b", "c"}
```

#### vals(tbl)

Returns all the values of the provided table `tbl`. Under the hood, this uses `next` which isn't implemented in LuaJIT,
so use with caution.

```lua
local tbl = { a = 1, b = 2, c = 3}
au.vals(tbl) -- returns { 1, 2, 3}
```

#### containsKey(tbl, key)

Returns `true` if `tbl` contains the key `key`, else `false`.
Like `keys`, this uses `next` under the hood, which is NYI in LuaJIT.

```lua
local tbl = { a = 1 }
au.containsKey(tbl, "a") -- returns true
```

#### containsValue(tbl, value)

Returns `true` if `tbl` contains the value `value`, else `false`.
Like `vals`, this uses `next` under the hood, which is NYI in LuaJIT.

```lua
local tbl = { a = 1 }
au.containsValue(tbl, 1) -- returns true
```

### Collection Utilities

These specifically work on one-dimensional tables (lists / arrays / collections)

#### contains(coll, x)

Returns `true` if `coll` contains `x`, else `false`

```lua
local coll = { 1, 2, 3, 4, 5}
au.contains(coll, 4) -- returns true
```

#### each(coll, fn)

Executes `fn` for every element in `coll`. Returns nothing.

```lua
local x = 0
local coll = { 1, 2, 3, 4, 5}
au.each(coll, function(e) x = x + e end)
print(x) -- prints 15
```

#### groupBy(coll, fn)

Returns a table where the elements in `coll` are grouped by the result of `fn` on each element.

```lua
local coll = { 1, 1, 1, 1, 2, 3, 4, 5 }
au.groupBy(coll, au.equals(1))
-- returns a table in the form of
-- { [false] = 2, 3, 4, 5
--   [true] =  1, 1, 1, 1}
```

### Filters

These functions perform different types of filtering operations on a collection.

#### filter(coll, fn)

Returns a collection containing the elements of `coll` where the return of `fn(element)` was true

```lua
local coll = { 1, 1, 1, 1, 2, 3, 4, 5 }
au.filter(coll, au.equals(1)) -- returns { 1, 1, 1, 1 }
```

#### remove(coll, fn)

The opposite of `filter`. This will return a new collection containing the elements of `coll`
where the return of `fn(element)` is `false`

```lua
local coll = { 1, 1, 1, 1, 2, 3, 4, 5 }
au.remove(coll, au.equals(1)) -- returns { 2, 3, 4, 5 }
```

#### keep(coll, fn)

Like `filter` but removes all elements where `fn(element)` returns `nil`.

```lua
local function isOneElseNil(x)
  if x == 1 then
    return 1
  end
  return nil
end

local coll = { 1, 1, 1, 1, 2, 3, 4, 5 }
au.keep(coll, isOneElseNil(x)) -- returns { 1, 1, 1, 1 }
```

### Checks

Each of these functions will take a collection, and a predicate function, and return a boolean.

#### any(coll, fn)

Returns `true` if any element of `coll` meets the predicate function `fn`

```lua
local coll = { 2, 3, 1, 4 }
au.any(coll, au.equals(1)) -- returns true
```

#### every(coll, fn)

Like `any`, however *every* element must meet the predicate function `fn`

```lua
local coll = { 2, 3, 1, 4 }

au.every(coll, au.equals(1)) -- returns false
```

### Mapping Functions

These functions take a collection, and map their value to a new value.

#### map(coll, fn)

Returns a new collection with every element in `coll` mapped by `fn(element)`

```lua
local coll = { 1, 2, 3, 4 }
au.map(coll, au.inc) -- returns { 2, 3, 4, 5 }
```

#### mapTo(coll, fn)

Returns a table, with each element in `coll` as a key, and `fn(element)` as its value.

```lua
local keys = { "a", "b", "c", "d"}
local values = { 1, 2, 3, 4 }
au.mapTo(coll, function(key, index) return values[index] end) -- returns { a = 1, b = 2, c = 2, d = 3 }
```

#### mapBy(coll, fn)

The inverse of `mapTo`. Returns a table where every element in `coll` as a value, and `fn(element)` as its key.

```lua
local coll = { 1, 2, 3, 4 }
au.mapBy(coll, au.inc) -- returns { 2 = 1, 3 = 2, 4 = 3, 5 = 4 }
```

### Generators

Generators are intended to be used with the `for` loop construct. Currently there is only one, `sustain`.

#### sustain(x, n)

Sustain repeats `x` endlessly. Optionally takes an `n` component, which will repeat `n` times.
(Ideally this would be called `repeat`, however that is a reserved keyword in lua.)

```lua
local coll = {}
for x in au.sustain(5, 5) do
  table.insert(coll, x)
end

print(#coll) -- prints 5
au.every(coll, au.equals(5)) -- returns true
```

### Reducers

These perform reductions on collections.

#### reduce(coll, fn, init)

Performs a left-to-right reduction of `coll` using `fn` with `init` as the initial value.
If `init` is nil, or not provided, then the first element of `coll` is used instead.

```lua
local coll = { 1, 2, 3, 4 }
au.reduce(coll, function(acc, i) return acc + i end, 0) -- returns 10
-- this can be simplified to
au.reduce(coll, au.add)
```

#### reduceKeyValue(tbl, fn, init)

Performs a left-to-right reduction of the entires in `tbl` using `fn` with `init` as the initial value.
Unlike `reduce`, `init` is for now, required.

Like `keys` and `values`, this makes use of `pairs` which is NYI in LuaJIT.

```lua
local coll = { 1 = 1, 2 = 2, 3 = 3, 4 = 4 }
local function tripAdd(a, b, c)
  return a + b + c
end

au.reduceKeyValue(coll, tripAdd, 0) -- returns 20
```
