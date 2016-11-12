require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/encryption.lua"

local default_config = {
  encrypt = {
    name = true,
    description = false,
    directives = true,
    shortdescription = false
  }
}

local config

local encrypt = encryption.encrypt
local encryptItem = function(v)
  if config.encrypt.name then v.name = encrypt(v.name) end
  if v.parameters then
    if config.encrypt.shortdescription and v.parameters.shortdescription then v.parameters.shortdescription = encrypt(v.parameters.shortdescription) end
    if config.encrypt.description and v.parameters.description then v.parameters.description = encrypt(v.parameters.description) end
    if config.encrypt.directives and v.parameters.directives then v.parameters.directives = encrypt(v.parameters.directives) end
  end
  v.encrypted = config.encrypt
  return v
end

local decrypt = encryption.decrypt
local decryptItem = function(v)
  encrypted = v.encrypted or {}
  if encrypted.name ~= false then v.name = decrypt(v.name) end
  if v.parameters then
    if encrypted.shortdescription ~= false and v.parameters.shortdescription then v.parameters.shortdescription = decrypt(v.parameters.shortdescription) end
    if encrypted.description ~= false and v.parameters.description then v.parameters.description = decrypt(v.parameters.description) end
    if encrypted.directives ~= false and v.parameters.directives then v.parameters.directives = decrypt(v.parameters.directives) end
  end
  return v
end

function init()
  -- Ensure a key exists.
  if not encryption.getKey() then encryption.generateKey() end

  -- Set configuration
  local cfg = root.getConfigurationPath("storedOutfits")
  if not cfg then
    root.setConfigurationPath("storedOutfits", default_config)
    config = default_config
  else
    config = cfg
  end

  local heldItem = player.primaryHandItem()

  -- Remove previous outfit item.
  heldItem.count = nil
  if player.hasCountOfItem(heldItem) > 1 then
    heldItem.count = 1
    player.consumeItem(heldItem)
  end

  local newOutfit = heldItem and heldItem.parameters and heldItem.parameters.outfit or {}
  for k,v in pairs(newOutfit) do
    v = decryptItem(v)
    if not pcall(function() root.itemConfig(v.name)end) then
      sb.logError("StoredOutfits: Could not read an outfit. Slot: %s. Item: %s.\nYou do not seem to have the right encryption key, or the item simply doesn't exist.", k, v.name)
      return
    end
    newOutfit[k] = v
  end

  -- Store previous items.
  local oldHead, oldChest, oldLegs, oldBack =
    player.equippedItem("headCosmetic"),
    player.equippedItem("chestCosmetic"),
    player.equippedItem("legsCosmetic"),
    player.equippedItem("backCosmetic")

  -- Equip new items.
  player.setEquippedItem("headCosmetic", newOutfit.head)
  player.setEquippedItem("chestCosmetic", newOutfit.chest)
  player.setEquippedItem("legsCosmetic", newOutfit.legs)
  player.setEquippedItem("backCosmetic", newOutfit.back)

  -- Create new outfit item.
  local item = root.assetJson("/interface/storedOutfits/template.json")
  local oldOutfit = {
    head = oldHead,
    chest = oldChest,
    legs = oldLegs,
    back = oldBack
  }

  -- Create inventory icon. Currently does not support color values.
  local oldIcon = item.parameters.inventoryIcon
  item.parameters.inventoryIcon = jarray()

  if oldHead then
    local cfg = root.itemConfig(oldHead.name)
    table.insert(item.parameters.inventoryIcon, { image = cfg.directory .. cfg.config.inventoryIcon, position = {0, 0} })
  end

  if oldChest then
    local cfg = root.itemConfig(oldChest.name)
    table.insert(item.parameters.inventoryIcon, { image = cfg.directory .. cfg.config.inventoryIcon, position = {16, 0} })
  end

  if oldLegs then
    local cfg = root.itemConfig(oldLegs.name)
    table.insert(item.parameters.inventoryIcon, { image = cfg.directory .. cfg.config.inventoryIcon, position = {0, -16} })
  end

  if oldBack then
    local cfg = root.itemConfig(oldBack.name)
    table.insert(item.parameters.inventoryIcon, { image = cfg.directory .. cfg.config.inventoryIcon, position = {16, -16} })
  end

  if #item.parameters.inventoryIcon == 0 then item.parameters.inventoryIcon = oldIcon end

  for k,v in pairs(oldOutfit) do
    v = encryptItem(v)

    oldOutfit[k] = v
  end

  item.parameters.outfit = oldOutfit

  -- Give new outfit item.
  item.count = nil
  if not player.hasItem(item) then
    item.count = 1
    player.giveItem(item)
  end

  -- Close invisible interface.
  pane.dismiss()

end

function update(dt) end
