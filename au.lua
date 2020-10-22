local au = {}

-- ============================================================================
-- HELPERS
-- ============================================================================

-- Returns true if x is not nil, otherwise returns false.
function au.some(x)
  return x ~= nil
end

-- Returns true if `x` is nil, otherwise returns false.
function au.none(x)
  return x == nil
end

-- Returns x
function au.identity(x)
  return x
end

-- Increments x by one
function au.inc(x)
  return x + 1
end

-- Decrements x by 1
function au.dec(x)
  return x - 1
end

-- Returns a + b
function au.add(a, b)
  return a + b
end

-- Returns a - b
function au.sub(a, b)
  return a - b
end

-- Returns true if `a` and `b` are equal, otherwise false.
-- If provided only `a`, returns a function that takes one parameter, `b`
-- That will return true if `a` == `b`, otherwise false.
function au.equals(a, b)
  if au.some(b) then
    return a == b
  end
  return function(b) return a == b end
end

-- Returns a function that will always return `x`
function au.constantly(x)
  return function(...) return x end
end

-- Returns a function that returns the complement of whatever is passed to it.
function au.complement(fn)
  return function(...) return not fn(...) end
end

-- ============================================================================
-- TABLE
-- ============================================================================

-- Retrieves the value of `k` in the table `tbl`. Returns nil or, if provided
-- `default` if the value is nil.
function au.get(tbl, k, default)
  local result = tbl[k]
  if au.none(result) and au.some(default) then
    return default
  end
  return result
end

-- Returns all the keys of the given table.
-- Uses `pairs` which under the hood uses `next` which is NYI in LuaJIT
function au.keys(tbl)
  local keys = {}
  for key in pairs(tbl) do
    table.insert(keys, key)
  end
  return keys
end

-- Returns all the values of the given table.
-- Uses `pairs` which under the hood uses `next` which is NYI in LuaJIT
function au.vals(tbl)
  local values = {}
  for _, value in pairs(tbl) do
    table.insert(values, value)
  end
  return values
end

-- Returns true if `x` exists in `y`, otherwise false.
function au.contains(coll, x)
  for _, elem in ipairs(coll) do
    if elem == x then
      return true
    end
  end
  return false
end

-- Returns true if `tbl` contains the key `key`, otherwise false.
function au.containsKey(tbl, key)
  return au.contains(au.keys(tbl), key)
end

-- Returns true if `tbl` contains the value `value`, otherwise false.
-- Uses `au.vals` under the hood, which uses `pairs` and `next`, NYI in LuaJIT
function au.containsValue(tbl, value)
  return au.contains(au.vals(tbl), value)
end

-- Iterates over every element in `coll` executing function `fn`. Has no return.
function au.each(coll, fn)
  for i, elem in ipairs(coll) do
    fn(elem, i)
  end
end

-- Returns a table where the elements in `coll` are group by the result
-- of `fn` on each element.
function au.groupBy(coll, fn)
  local result = {}
  for i, elem in ipairs(coll) do
    local group = fn(elem)
    if au.none(result) then
      result[group] = {}
    end
    table.insert(result[group], elem)
  end
  return result
end

-- =============================================================================
-- FILTERS
-- =============================================================================

-- Returns a new collection with all elements of `coll` where `fn(elem)` returns
-- true.
function au.filter(coll, fn)
  local result = {}
  for i, elem in ipairs(coll) do
    if fn(elem, i) then
      table.insert(result, elem)
    end
  end
  return result
end

-- Returns a new collection with all elements of `coll` where `fn(elem)` returns
--  true removed.
function au.remove(coll, fn)
  return au.filter(coll, au.complement(fn))
end

-- Returns a new collection with every element where `fn(elem)` did not return nil.
function au.keep(coll, fn)
  local result = {}
  for i, elem in ipairs(coll) do
    if au.some(fn(elem, i)) then
      table.insert(result, elem)
    end
  end
  return result
end

-- ============================================================================
-- PRED CHECKING
-- ============================================================================

-- Returns true if at least one element `coll` meets the test `fn(elem) == true`
function au.any(coll, fn)
  for i, elem in ipairs(coll) do
    if fn(elem, i) then
      return true
    end
  end
  return false
end

-- Returns true if every element `coll` meets the test `fn(elem) == true`
function au.every(coll, fn)
  for i, elem in ipairs(coll) do
    if not fn(elem, i) then
      return false
    end
  end
  return true
end

-- ============================================================================
-- MAPPING
-- ============================================================================

-- Returns a new collection containing the result of `fn(elem)` from `coll`
function au.map(coll, fn)
  local result = {}
  for i, elem in ipairs(coll) do
    table.insert(result, fn(elem, i))
  end
  return result
end

-- Returns a new table where the mapping is from `elem => fn(elem)`
function au.mapTo(coll, fn)
  local result = {}
  for i, elem in ipairs(coll) do
    result[elem] = fn(elem, i)
  end
  return result
end

-- Returns a new table where the mapping is from `fn(elem) => elem`
function au.mapBy(coll, fn)
  local result = {}
  for i, elem in ipairs(coll) do
    result[fn(elem, i)] = elem
  end
  return result
end

-- ============================================================================
-- GENERATORS
-- ============================================================================

-- Returns an iterator where value `x` is returned indefinitely.
-- If `n` is provided, will repeat `n` times before exiting.
function au.sustain(x, n)
  local count = 0
  return function()
    if au.some(n) then
      if count == n then
        return nil
      end
      count = count + 1
    end
    return x
  end
end

-- ============================================================================
-- REDUCING
-- ============================================================================

-- Performs a left-to-right reduction of `coll` using `fn` with `init` as the
-- first value. If `init` is nil or not provided, then the first element of `coll`
-- is used.
function au.reduce(coll, fn, init)
  local result = init
  local startIndex = 1

  if au.none(result) then
    result = coll[1]
    startIndex = 2
  end

  for i = startIndex, #coll do
    result = fn(result, coll[i], i)
  end

  return result
end

-- Performs a left-to-right reduction of the entries of `tbl` using `fn` with
-- `init` as the first value. Uses `pairs` and `next` under the hood, NYI in
-- LuaJIT
function au.reduceKeyValue(tbl, fn, init)
  for k, v in pairs(tbl) do
    init = fn(init, k, v)
  end
  return init
end

return au
