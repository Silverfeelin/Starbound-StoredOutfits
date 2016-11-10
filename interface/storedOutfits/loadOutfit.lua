require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/encryption.lua"

local encrypt = encryption.encrypt
local decrypt = encryption.decrypt

function init()
  -- Ensure a key exists.
  if not encryption.getKey() then encryption.generateKey() end

  local heldItem = player.primaryHandItem()

  -- Remove previous outfit item.
  player.consumeItem(heldItem)

  local newOutfit = heldItem and heldItem.parameters and heldItem.parameters.outfit or {}
  for k,v in pairs(newOutfit) do
    v.name = decrypt(v.name)
    if v.parameters then
      if v.parameters.shortdescription then v.parameters.shortdescription = decrypt(v.parameters.shortdescription) end
      if v.parameters.description then v.parameters.description = decrypt(v.parameters.description) end
      if v.parameters.directives then v.parameters.directives = decrypt(v.parameters.directives) end
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
    v.name = encrypt(v.name)
    if v.parameters then
      if v.parameters.shortdescription then v.parameters.shortdescription = encrypt(v.parameters.shortdescription) end
      if v.parameters.description then v.parameters.description = encrypt(v.parameters.description) end
      if v.parameters.directives then v.parameters.directives = encrypt(v.parameters.directives) end
    end

    oldOutfit[k] = v
  end

  item.parameters.outfit = oldOutfit

  -- Give new outfit item.
  player.giveItem(item)

  sb.logInfo("NEW\n%s\nOLD\n%s", sb.printJson(newOutfit), sb.printJson(oldOutfit))
  -- Close invisible interface.
  pane.dismiss()

end

function update(dt) end
