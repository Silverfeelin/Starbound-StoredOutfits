require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()

  local heldItem = player.primaryHandItem()
  local newOutfit = heldItem and heldItem.parameters and heldItem.parameters.outfit or {}

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

  -- Remove previous outfit item.
  player.consumeItem(heldItem)

  -- Create new outfit item.
  local item = root.assetJson("/interface/storedOutfits/template.json")
  item.parameters.outfit = {
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

  -- Give new outfit item.
  player.giveItem(item)

  -- Close invisible interface.
  pane.dismiss()

end

function update(dt) end
