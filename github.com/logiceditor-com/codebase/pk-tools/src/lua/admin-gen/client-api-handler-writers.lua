--------------------------------------------------------------------------------
-- client-api-handler-writers.lua: routines creating code of handlers
-- This file is a part of pk-tools library
-- Copyright (c) Alexander Gladysh <ag@logiceditor.com>
-- Copyright (c) Dmitry Potapov <dp@logiceditor.com>
-- See file `COPYRIGHT` for the license
--------------------------------------------------------------------------------

local make_loggers = import 'pk-core/log.lua' { 'make_loggers' }
local log, dbg, spam, log_error = make_loggers("client-api-handler-writers", "CAW")

--------------------------------------------------------------------------------

local arguments,
      optional_arguments,
      method_arguments
      = import 'lua-nucleo/args.lua'
      {
        'arguments',
        'optional_arguments',
        'method_arguments'
      }

local Q, CR, NPAD, write_file_using_template
      = import 'admin-gen/misc.lua'
      {
        'Q', 'CR', 'NPAD', 'write_file_using_template'
      }

--------------------------------------------------------------------------------

local make_table_handler_writer = function(operation, comment)
  return function(name, codeblock_before_insert_or_update, fields, template_dir, dir_out)
    local values = {}

    values.HEADER = [[
--------------------------------------------------------------------------------
-- ]] .. name .. "/" .. operation .. ".lua: " .. comment .. CR .. [[
--------------------------------------------------------------------------------
-- WARNING! Do not change manually.
-- Generated by generate-client-api-schema.lua
--------------------------------------------------------------------------------
]]

    values.REQUEST_PREFIX = name
    values.TABLE_NAME = name
    values.ITEM_FIELDS = fields
    values.NEW_ITEM_FIELDS = fields
    values.UPDATED_ITEM_FIELDS = fields
    values.CODEBLOCK_BEFORE_INSERT_OR_UPDATE =
      codeblock_before_insert_or_update or ""

    -- TODO: Maybe we should not fail on item not found?
    values.CODEBLOCK_ON_ITEM_NOT_FOUND = '      fail("NOT_FOUND", "item not found")'
    --values.CODEBLOCK_ON_ITEM_NOT_FOUND = '      return false, "NOT_FOUND"'

    write_file_using_template(
      values,
      dir_out .. name .. "/" .. operation .. ".lua",
      template_dir .. operation .. ".lua.template"
    )
  end
end

--------------------------------------------------------------------------------

local make_serialized_list_handler_writer = function(operation, comment)
  return function(
      name, serialized_list_name,
      sl_api_maker, fields,
      template_dir,
      dir_out
    )

    local values = {}

    values.HEADER = [[
--------------------------------------------------------------------------------
-- ]] .. name .. "-".. serialized_list_name .. "/" .. operation .. ".lua: "
.. comment .. CR .. [[
--------------------------------------------------------------------------------
-- WARNING! Do not change manually.
-- Generated by generate-client-api-schema.lua
--------------------------------------------------------------------------------
]]

    values.REQUEST_PREFIX = name .. "-" .. serialized_list_name
    values.MAKE_SERIALIZED_LIST_API = sl_api_maker
    values.ITEM_FIELDS = fields
    values.NEW_ITEM_FIELDS = fields
    values.UPDATED_ITEM_FIELDS = fields

    write_file_using_template(
      values,
      dir_out .. name .. "/" .. serialized_list_name .. "/" .. operation .. ".lua",
      template_dir .. "serialized_list/" .. operation .. ".lua.template"
    )
  end
end

--------------------------------------------------------------------------------

local write_table_handlers = function(
    metadata, table_name, password_field, template_dir, dir_out,
    existing_fields, new_fields, updated_fields
  )
  metadata = metadata or {}

  local write_delete_handler = make_table_handler_writer(
      "delete", "delete items from DB table"
    )
  local write_get_by_id_handler = make_table_handler_writer(
      "get_by_id", "get item by id from DB table"
    )
  local write_insert_handler = make_table_handler_writer(
      "insert", "insert item to DB table"
    )
  local write_list_handler = make_table_handler_writer(
      "list", "list all values from DB table"
    )
  local write_update_handler = make_table_handler_writer(
      "update", "update item in DB table"
    )
  local write_update_or_insert_handler = make_table_handler_writer(
      "update_or_insert", "update or insert item in DB table"
    )

  local codeblock_before_insert_or_update = nil

  if password_field then
    codeblock_before_insert_or_update = [[
    if data.]] .. password_field .. [[ and data.]] .. password_field .. [[ ~= "" then
      data.]] .. password_field .. [[ = md5.sumhexa(data.]] .. password_field .. [[ .. "_" .. SALT_ADMIN)
    else
      data.]] .. password_field .. [[ = nil
    end]]
  end

  if not metadata.read_only then
    write_insert_handler(
        table_name,
        codeblock_before_insert_or_update,
        new_fields,
        template_dir,
        dir_out
      )
    if not metadata.append_only then
      write_update_handler(
          table_name,
          codeblock_before_insert_or_update,
          updated_fields,
          template_dir,
          dir_out
        )
      if metadata.enable_update_or_insert then
        write_update_or_insert_handler(
            table_name,
            codeblock_before_insert_or_update,
            updated_fields,
            template_dir,
            dir_out
          )
      end
    end
    if not metadata.append_only and not metadata.prohibit_deletion then
      write_delete_handler(
        table_name,
        nil, -- codeblock_before_insert_or_update
        nil, -- new fields
        template_dir,
        dir_out
      )

    end
  end

  write_get_by_id_handler(
      table_name,
      nil, -- codeblock_before_insert_or_update
      existing_fields,
      template_dir,
      dir_out
    )
  write_list_handler(
      table_name,
      nil, -- codeblock_before_insert_or_update
      existing_fields,
      template_dir,
      dir_out
    )
end

--------------------------------------------------------------------------------

local write_serialized_list_handlers = function(
    table_metadata,
    list_metadata,
    table_name,
    object_id_field,
    serialized_list_name,
    serialized_item_id_field,
    template_dir,
    dir_out,
    existing_fields, new_fields, updated_fields
  )
  table_metadata = table_metadata or {}
  list_metadata = list_metadata or {}

  local write_delete_handler = make_serialized_list_handler_writer(
      "delete", "delete items from serialized list"
    )
  local write_get_by_id_handler = make_serialized_list_handler_writer(
      "get_by_id", "get item by id from serialized list"
    )
  local write_insert_handler = make_serialized_list_handler_writer(
      "insert", "insert item to serialized list"
    )
  local write_list_handler = make_serialized_list_handler_writer(
      "list", "list all values from serialized list"
    )
  local write_update_handler = make_serialized_list_handler_writer(
      "update", "update item in serialized list"
    )

  local sl_api_maker = [[local table_api = make_serialized_list_api(
        api_context:db():]] .. table_name .. [[(),
        "]] .. object_id_field .. [[", "]] .. serialized_list_name .. [[", param.list_container_id,
        "]] .. serialized_item_id_field .. [["
      )]]


  local read_only = table_metadata.read_only or list_metadata.read_only
  local append_only = list_metadata.append_only
  local prohibit_deletion = list_metadata.prohibit_deletion

  if table_metadata.read_only_fields then
    read_only = read_only or table_metadata.read_only_fields[serialized_list_name]
  end

  if not read_only then
    write_insert_handler(
        table_name, serialized_list_name,
        sl_api_maker, new_fields, template_dir, dir_out
      )
    if not append_only then
      write_update_handler(
          table_name, serialized_list_name,
          sl_api_maker, updated_fields, template_dir, dir_out
        )
    end
    if not append_only and not prohibit_deletion then
      write_delete_handler(
          table_name, serialized_list_name,
          sl_api_maker, nil, template_dir, dir_out
        )
    end
  end

  write_get_by_id_handler(
      table_name, serialized_list_name,
      sl_api_maker, existing_fields, template_dir, dir_out
    )
  write_list_handler(
      table_name, serialized_list_name,
      sl_api_maker, existing_fields, template_dir, dir_out
    )
end

--------------------------------------------------------------------------------

return
{
  write_table_handlers = write_table_handlers;
  write_serialized_list_handlers = write_serialized_list_handlers;
}
