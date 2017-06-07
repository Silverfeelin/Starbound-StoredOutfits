require "/scripts/storedOutfits/util.lua"

storedOutfits = {}
so = storedOutfits

local private = { preview = {} }
local public = so

local config, lookup

private.idleFrames = {
  arm = "idle.1",
  body = "idle.1"
}

local categories = {
  head = "headCosmetic",
  chest = "chestCosmetic",
  legs = "legsCosmetic",
  back = "backCosmetic"
}

local head = function() return player.equippedItem(categories["head"]), player.equippedItem("head") end
local chest = function() return player.equippedItem(categories["chest"]), player.equippedItem("chest") end
local legs = function() return player.equippedItem(categories["legs"]), player.equippedItem("legs") end
local back = function() return player.equippedItem(categories["back"]), player.equippedItem("back") end

function init()
  config = root.assetJson("/scripts/storedOutfits/storedOutfits.config")
  lookup = config.widgets
  private.outfits = status.statusProperty("storedOutfits")
  if not private.outfits then private.outfits = {} end

  widget.clearListItems(lookup.list)
  for _,v in pairs(private.outfits) do
    private.addListItem(v)
  end

  private.loadPreview()
end

function private.addListItem(data)
  local w = widget.addListItem(lookup.list)
  w = lookup.list .. "." .. w
  widget.setData(w, data)

  local head, chest, legs, back = data.head, data.chest, data.legs, data.back

  if head then
    local default = root.itemConfig(head.name)
    local dir = so_util.itemDirectives(head, default)
    local defaultImage = private.getDefaultImageForItem(default) .. dir
    widget.setImage(w .. ".head", defaultImage)
  end

  if chest then
    local default = root.itemConfig(chest.name)
    local defaultImage = private.getDefaultImageForItem(default)
    local dir = so_util.itemDirectives(chest, default)
    widget.setImage(w .. ".backSleeves", defaultImage[1] .. dir)
    widget.setImage(w .. ".chest", defaultImage[2] .. dir)
    widget.setImage(w .. ".frontSleeves", defaultImage[3] .. dir)
  end

  if legs then
    local default = root.itemConfig(legs.name)
    local dir = so_util.itemDirectives(legs, default)
    local defaultImage = private.getDefaultImageForItem(default) .. dir
    widget.setImage(w .. ".legs", defaultImage)
  end

  if back then
    local default = root.itemConfig(back.name)
    local dir = so_util.itemDirectives(back, default)
    local defaultImage = private.getDefaultImageForItem(default) .. dir
    widget.setImage(w .. ".back", defaultImage)
  end
end

function so.outfitSelected(w, d)
  local sel = widget.getListSelected("soOutfitScroll.list")
  if sel then
    private.selection = widget.getData(lookup.list .. "." .. sel)
    private.selectOutfit(private.selection)
  end
end

function private.selectOutfit(data)
  private.showHead(data.head)
  private.showChest(data.chest)
  private.showLegs(data.legs)
  private.showBack(data.back)
end

function so.save()
  local t = {}
  t["head"] = head()
  t["chest"] = chest()
  t["legs"] = legs()
  t["back"] = back()

  table.insert(private.outfits, t)

  status.setStatusProperty("storedOutfits", private.outfits)

  sb.logInfo("Saved %s", sb.printJson(t))
  private.addListItem(t)
end

function so.equip()
  local outfit = private.selection
  if outfit then
    player.setEquippedItem("headCosmetic", outfit.head)
    player.setEquippedItem("chestCosmetic", outfit.chest)
    player.setEquippedItem("legsCosmetic", outfit.legs)
    player.setEquippedItem("backCosmetic", outfit.back)
  end
end

function so.spawn()
  sb.logInfo("%s", widget.getListSelected("soOutfitScroll.list"))
end

function private.showHead(data)
  local defaultImage
  local dir = ""
  if not data then
    defaultImage = "/assetMissing"
  else
    local default = root.itemConfig(data.name)
    dir = so_util.itemDirectives(data, default)
    defaultImage = private.getDefaultImageForItem(default)
  end

  private.setWidgetImage(private.preview.custom[6], defaultImage .. dir)
end

function private.showChest(data)
  local defaultImage
  local dir = ""
  if not data then
    defaultImage = {"/assetMissing","/assetMissing","/assetMissing"}
  else
    local default = root.itemConfig(data.name)
    dir = so_util.itemDirectives(data, default)
    defaultImage = private.getDefaultImageForItem(default, true)
  end

  private.setWidgetImage(private.preview.custom[2], defaultImage[1] .. dir)
  private.setWidgetImage(private.preview.custom[5], defaultImage[2] .. dir)
  private.setWidgetImage(private.preview.custom[7], defaultImage[3] .. dir)
end

function private.showLegs(data)
  local defaultImage
  local dir = ""
  if not data then
    defaultImage = "/assetMissing"
  else
    local default = root.itemConfig(data.name)
    dir = so_util.itemDirectives(data, default)
    defaultImage = private.getDefaultImageForItem(default, true)
  end

  private.setWidgetImage(private.preview.custom[4], defaultImage .. dir)
end

function private.showBack(data)
  local defaultImage
  local dir = ""
  if not data then
    defaultImage = "/assetMissing"
  else
    local default = root.itemConfig(data.name)
    dir = so_util.itemDirectives(data, default)
    defaultImage = private.getDefaultImageForItem(default, true)
  end

  private.setWidgetImage(private.preview.custom[3], defaultImage .. dir)
end

--[[
  Loads the preview by adding layers to the preview widget.
]]
function private.loadPreview()
  local preview = lookup.preview

  local layers = {}

  local playerID = player.id()

  -- Fetch portrait and remove item layers
  local portrait = world.entityPortrait(playerID, "full")
  portrait = util.filter(portrait, function(item)
    return not item.image:find("^/items")
  end)

  -- Set the layer table, using the amount of layers found in the entity portrait as a guideline.
  local portraitFrames = #portrait
  layers = {
    portrait[1].image,
    portrait[2].image,
    portrait[3].image,
    portrait[4].image:gsub('%?addmask=[^%?]+',''),
    portrait[5].image
  }

  -- Update idle frame names.
  private.idleFrames = {
    arm = layers[1]:match('/%w+%.png:([%w%.]+)') or "idle.1",
    body = layers[5]:match('/%w+%.png:([%w%.]+)') or "idle.1"
  }

  if portraitFrames > 6 then layers[6] = portrait[6].image end
  if portraitFrames > 7 then layers[7] = portrait[7].image end
  layers[8] = portrait[#portrait].image

  -- Add the preview layers
  widget.clearListItems(preview)

  private.preview.default = {}
  private.preview.custom = {}

  table.insert(private.preview.custom, widget.addListItem(preview))
  private.layers = layers
  for i=1,8 do
    -- Add default layer
    local li = widget.addListItem(preview)
    if layers[i] then
      private.setWidgetImage(preview .. "." .. li .. ".image", layers[i])
    end
    table.insert(private.preview.default, preview .. "." .. li .. ".image")

    -- Add blank custom layer(s)
    local customLayers = (i == 1 or i == 5) and 2 or (i == 7 or i == 8) and 1 or 0
    for j=1,customLayers do
      table.insert(private.preview.custom, preview .. "." .. widget.addListItem(preview) .. ".image")
    end
  end
end

function private.getDefaultImageForItem(item, useCharacterFrames)
  local bodyFrame = useCharacterFrames and private.idleFrames.body or "idle.1"
  local armFrame = useCharacterFrames and private.idleFrames.arm or "idle.1"
  local category = item.config.category
  if category == "headwear" or category == "headarmour" then
    local image = so_util.fixImagePath(item.directory, player.gender() == "male" and item.config.maleFrames or item.config.femaleFrames) .. ":normal"
    return image
  elseif category == "chestwear" or category == "chestarmour" then
    local image = so_util.fixImagePath(item.directory, player.gender() == "male" and item.config.maleFrames.body or item.config.femaleFrames.body) .. ":" .. bodyFrame
    local imageBack = so_util.fixImagePath(item.directory, player.gender() == "male" and item.config.maleFrames.backSleeve or item.config.femaleFrames.backSleeve) .. ":" .. armFrame
    local imageFront = so_util.fixImagePath(item.directory, player.gender() == "male" and item.config.maleFrames.frontSleeve or item.config.femaleFrames.frontSleeve) .. ":" .. armFrame
    return {imageBack, image, imageFront}
  elseif category == "legwear" or category == "legarmour" then
    local image = so_util.fixImagePath(item.directory, player.gender() == "male" and item.config.maleFrames or item.config.femaleFrames) .. ":" .. bodyFrame
    return image
  elseif category == "backwear" or category == "backarmour" then
    local image = so_util.fixImagePath(item.directory, item.config.maleFrames) .. ":" .. bodyFrame
    return image
  end
end

function private.setWidgetImage(w, p)
  if not pcall(root.imageSize, p) then p = "/assetMissing.png" end
  widget.setImage(w, p)
end

function so.delete()
  local outfit = private.selection
  for k,v in pairs(private.outfits) do
    if equals(v, outfit, true) then
      private.outfits[k] = nil
      break
    end
  end

  widget.clearListItems(lookup.list)
  for _,v in pairs(private.outfits) do
    private.addListItem(v)
  end
end