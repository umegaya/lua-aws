-- originally from https://github.com/lubyk/xml/blob/master/xml/init.lua. thanks!
-- *MIT license* &copy Marcin Kalicinski 2006, 2009, Gaspard Bucher 2014.

local _M = {}

local insert = table.insert
local concat = table.concat

local function escape(v)
  if type(v) == 'boolean' then
    return v and 'true' or 'false'
  else
    return v:gsub('&','&amp;'):gsub('>','&gt;'):gsub('<','&lt;'):gsub("'",'&apos;')
  end
end

local function tagWithAttributes(data)
  local res = data.xml or 'table'
  for k,v in pairs(data) do
    if k ~= 'xml' and type(k) == 'string' then
      res = res .. ' ' .. k .. "='" .. escape(v) .. "'"
    end
  end
  return res
end

local function doDump(data, indent, output, last, depth, max_depth)
  if depth > max_depth then
    error(string.format("Could not dump table to XML. Maximal depth of %i reached.", max_depth))
  end

  if data[1] then
    insert(output, (last == 'n' and indent or '')..'<'..tagWithAttributes(data)..'>')
    last = 'n'
    local ind = indent..'  '
    for _, child in ipairs(data) do
      local typ = type(child)
      if typ == 'table' then
        doDump(child, ind, output, last, depth + 1, max_depth)
        last = 'n'
      elseif typ == 'number' then
        insert(output, tostring(child))
      else
        local s = escape(child)
        insert(output, s)
        last = 's'
      end
    end
    insert(output, (last == 'n' and indent or '')..'</'..(data.xml or 'table')..'>')
    last = 'n'
  else
    -- no children
    insert(output, (last == 'n' and indent or '')..'<'..tagWithAttributes(data)..'/>')
    last = 'n'
  end
end

-- Dump a lua table in the format described above and return an XML string. The
-- `max_depth` parameter is used to avoid infinite recursion in case a table
-- references one of its ancestors.
--
-- Default maximal depth is 3000.
function _M.build(table, max_depth)
  local max_depth = max_depth or 3000
  local res = {}
  doDump(table, '\n', res, 's', 1, max_depth)
  return concat(res, '')
end

xmlbuilder_mt = {}
xmlbuilder_mt.__index = xmlbuilder_mt
function xmlbuilder_mt:ele(name)
  local child = setmetatable({ xml = name }, xmlbuilder_mt)
  insert(self, child)
  return child
end
function xmlbuilder_mt:att(key, value)
  self[key] = value
end
function xmlbuilder_mt:txt(value)
  self[1] = value
end

function _M.create(root_name)
  return setmetatable({xml = root_name}, xmlbuilder_mt)
end

return _M

