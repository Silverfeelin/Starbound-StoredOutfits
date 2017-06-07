so_util = {}

local private = {}
local public = so_util

function public.itemDirectives(item, default)
  if item.parameters.directives then return item.parameters.directives end

  if not default then default = root.itemConfig(item.name) end
  if default.config.colorOptions and item.parameters.colorIndex then
    local colorIndex = item.parameters.colorIndex
    local colorOptions = default.config.colorOptions

    local index = colorIndex % #colorOptions + 1
    return public.colorOptionToDirectives(colorOptions[index])
  end

  return ""
end

function public.colorOptionToDirectives(colorOption)
  sb.logInfo("converting %s", sb.printJson(colorOption))
  if not colorOption then return "" end
  local dir = "?replace"
  for k,v in pairs(colorOption) do
    dir = dir .. ";" .. k .. "=" .. v
  end
  return dir
end

function public.fixImagePath(path, image)
  return not path and image or image:find("^/") and image or (path .. image):gsub("//", "/")
end

function equals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end