--------------------------------------------------------------------------------
--- Generates list of test files to be run
-- @module test.test-lib.generate-test-list
-- This file is a part of lua-nucleo library
-- @copyright lua-nucleo authors (see file `COPYRIGHT` for the license)
--------------------------------------------------------------------------------

local string, io, os = string, io, os

if not pcall(require, 'luarocks.require') then
  io.write("Warning: luarocks not found.")
end

local lfs
do
  local ok
  ok, lfs = pcall(require, 'lfs')
  if not ok then
    error("Failed to require 'lfs'. Skipping test list refresh.")
  end
end

local function find_all_files(path, regexp, dest)
  dest = dest or {}
  for filename in lfs.dir(path) do
    if filename ~= "." and filename ~= ".." then
      local filepath = path .. "/" .. filename
      local attr = lfs.attributes(filepath)
      if attr.mode == "directory" then
        find_all_files(filepath, regexp, dest)
      elseif filename:find(regexp) then
        dest[#dest + 1] = filename
      end
    end
  end
  return dest
end

-- parsing input string
local input_string = select(1, ...)
local lib_path, case_paths, file_to_save, extension
if input_string ~= nil then
  local input_table = { }
  for word in input_string:gmatch("[%a,._/%-]+") do
    input_table[#input_table + 1] = word
  end

  local extract_parameter = function()
    assert(#input_table > 0, "failed to extract parameter: table is empty")
    return table.remove(input_table, 1)
  end

  lib_path = extract_parameter()
  file_to_save = extract_parameter()
  extension = extract_parameter()
  case_paths = {}
  while #input_table > 0 do
    case_paths[#case_paths + 1] = extract_parameter()
  end

  assert(#case_paths > 0, "at least one case path need to process")
end

lib_path = lib_path or "lua-nucleo"
if #case_paths == 0 then
  case_paths[0] = "test/cases"
end
file_to_save = file_to_save or "test/test-list.lua"
extension = extension or ".lua"

-- get all library files
local lib_files = find_all_files(lib_path, extension)
table.sort(lib_files)

-- get all test cases
local cases = { }
local case_infos = { }
for i = 1, #case_paths do
  local case_path = case_paths[i]
  local case_type = case_path:sub(case_path:find("/") + 1, -1)
  assert(case_type and #case_type > 0, "unable to detect case type")
  local folder_cases = find_all_files(case_path, extension)
  for j = 1, #folder_cases do
    cases[#cases + 1] = folder_cases[j]
    case_infos[folder_cases[j]] =
    {
      type = case_type;
      path = case_path .. "/" .. folder_cases[j];
    }
  end
end
table.sort(cases)

-- check all library files got test cases
io.write("Test list generation check:")
for i = 1, #lib_files do
  local lib_file = lib_files[i]
  lib_file = lib_file:match("([%w%-_]+).lua")
  local match_found = false
  io.write(lib_file .. ": ")
  lib_file = lib_file:gsub("%-", "%%%-") -- replace "-" with "%-" in names
  for j = 1, #cases do
    local case_j = cases[j]
    if string.match(case_j, "%-" .. lib_file .. "[%-%.]") then
      match_found = true
      io.write(case_j, "; ")
    end
  end
  if match_found == false then
    io.write("no tests found.\nTest list generation failed!\n")
    os.remove("test/test-list.lua")
    return nil
  end
  io.write("\n")
end
io.write("OK\n")

-- write test list
io.write("Test list file write:")
local file, err = io.open(file_to_save, "w")
file:write("--------------------------------------------------------------------------------\n"
        .. "-- test-list.lua: the list of all tests in the library\n"
        .. "-- This file is generated by lua-nucleo library\n"
        .. "-- Copyright (c) lua-nucleo authors"
        .. "(see file `COPYRIGHT` for the license)\n"
        .. "--------------------------------------------------------------------------------\n\n"
        .. "return\n"
        .. "{\n")
for i = 1, #cases do
  local case_info = case_infos[cases[i]]
  file:write("  {\n")
  file:write("    type = '" .. case_info.type .. "';\n")
  file:write("    path = '" .. case_info.path .. "';\n")
  file:write("  };\n")
end
file:write("}\n")
file:close()
io.write("OK\n")