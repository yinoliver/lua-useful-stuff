-- Sets.

local list   = require "std.base"
local object = require "std.object"

local new -- forward declaration

-- Primitive methods (know about representation)
-- The representation is a table whose tags are the elements, and
-- whose values are true.

--- Say whether an element is in a set
-- @param s set
-- @param e element
-- @return <code>true</code> if e is in set, <code>false</code>
-- otherwise
local function member (s, e)
  return rawget (s.contents, e) == true
end

--- Insert an element into a set
-- @param s set
-- @param e element
-- @return the modified set
local function insert (s, e)
  rawset (s.contents, e, true)
  return s
end

--- Delete an element from a set
-- @param s set
-- @param e element
-- @return the modified set
local function delete (s, e)
  rawset (s.contents, e, nil)
  return s
end

--- Iterator for sets
-- TODO: Make the iterator return only the key
local function elems (s)
  return pairs (s.contents)
end


-- High level methods (representation-independent)

local difference, symmetric_difference, intersection, union, subset, equal

--- Find the difference of two sets
-- @param s set
-- @param t set
-- @return s with elements of t removed
function difference (s, t)
  if object.type (t) == "table" then
    t = new (unpack (t))
  end
  local r = new ()
  for e in elems (s) do
    if not member (t, e) then
      insert (r, e)
    end
  end
  return r
end

--- Find the symmetric difference of two sets
-- @param s set
-- @param t set
-- @return elements of s and t that are in s or t but not both
function symmetric_difference (s, t)
  if object.type (t) == "table" then
    t = new (unpack (t))
  end
  return difference (union (s, t), intersection (t, s))
end

--- Find the intersection of two sets
-- @param s set
-- @param t set
-- @return set intersection of s and t
function intersection (s, t)
  if object.type (t) == "table" then
    t = new (unpack (t))
  end
  local r = new ()
  for e in elems (s) do
    if member (t, e) then
      insert (r, e)
    end
  end
  return r
end

--- Find the union of two sets
-- @param s set
-- @param t set or set-like table
-- @return set union of s and t
function union (s, t)
  if object.type (t) == "table" then
    t = new (unpack (t))
  end
  local r = new ()
  for e in elems (s) do
    insert (r, e)
  end
  for e in elems (t) do
    insert (r, e)
  end
  return r
end

--- Find whether one set is a subset of another
-- @param s set
-- @param t set
-- @return <code>true</code> if s is a subset of t, <code>false</code>
-- otherwise
function subset (s, t)
  if object.type (t) == "table" then
    t = new (unpack (t))
  end
  for e in elems (s) do
    if not member (t, e) then
      return false
    end
  end
  return true
end

--- Find whether one set is a proper subset of another
-- @param s set
-- @param t set
-- @return <code>true</code> if s is a proper subset of t, false otherwise
function propersubset (s, t)
  if object.type (t) == "table" then
    t = new (unpack (t))
  end
  return subset (s, t) and not subset (t, s)
end

--- Find whether two sets are equal
-- @param s set
-- @param t set
-- @return <code>true</code> if sets are equal, <code>false</code>
-- otherwise
function equal (s, t)
  return subset (s, t) and subset (t, s)
end

-- Public interface
local M = {
  delete               = delete,
  difference           = difference,
  elems                = elems,
  equal                = equal,
  insert               = insert,
  intersection         = intersection,
  member               = member,
  propersubset         = propersubset,
  subset               = subset,
  symmetric_difference = symmetric_difference,
  union                = union,
}

--- Make a list into a set
-- @param l list
-- @return set
function new (...)
  local s = object {
    -- Derived object type.
    _type = "set",

    -- Metamethods.
    __add = union,                -- set + table = union
    __sub = difference,           -- set - table = set difference
    __mul = intersection,         -- set * table = intersection
    __div = symmetric_difference, -- set / table = symmetric difference
    __le  = subset,               -- set <= table = subset
    __lt  = propersubset,         -- set < table = proper subset

    __totable  = function (self)
	           local t = {}
		   for e in elems (self) do
                     table.insert (t, e)
                   end
		   table.sort (t)
	           return t
		 end,

    -- set:method ()
    __index = M,

    -- Set elements
    contents = {},
  }

  -- Initialise.
  for e in list.elems {...} do
    insert (s, e)
  end

  return s
end

-- Inject `new` method into public interface.
M.new = new

return setmetatable (M, {
  -- Sugar to call new automatically from module table.
  __call = function (self, t)
    return new (unpack (t))
  end,
})
