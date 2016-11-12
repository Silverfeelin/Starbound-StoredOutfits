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

  local oldIcon = item.parameters.inventoryIcon
  item.parameters.inventoryIcon = jarray()

  table.insert(item.parameters.inventoryIcon, { position = {0, 0}, image = "/assetMissing.png?replace;00000000=ffffff;ffffff00=ffffff?setcolor=ffffff?scalenearest=1?crop=0;0;13;17?blendmult=/objects/outpost/customsign/signplaceholder.png;0;0?replace;01000101=000000FF;01000201=000000FF;01000301=000000FF;01000401=000000FF;01000501=000000FF;01000601=000000FF;01000701=000000FF;01000801=000000FF;02000101=000000FF;02000201=251C0BFF;02000301=403316FF;02000401=403316FF;02000501=463818FF;02000601=463818FF;02000701=463818FF;02000801=403316FF;03000101=000000FF;03000201=251C0BFF;03000301=463818FF;03000401=403316FF;03000501=403316FF;03000601=403316FF;03000701=403316FF;03000801=403316FF;04000101=000000FF;04000201=251C0BFF;04000301=463818FF;04000401=463818FF;04000501=463818FF;04000601=403316FF;04000701=463818FF;04000801=463818FF;05000101=000000FF;05000201=251C0BFF;05000301=251C0BFF;05000401=251C0BFF;05000501=251C0BFF;05000601=251C0BFF;05000701=251C0BFF;05000801=251C0BFF;06000101=000000FF;06000201=33120FFF;06000301=33120FFF;06000401=33120FFF;06000501=33120FFF;06000601=33120FFF;06000701=33120FFF;06000801=33120FFF;07000101=000000FF;07000201=521D19FF;07000301=521D19FF;07000401=521D19FF;07000501=521D19FF;07000601=521D19FF;07000701=521D19FF;07000801=521D19FF;08000101=000000FF;08000201=33120FFF;08000301=33120FFF;08000401=33120FFF;08000501=33120FFF;08000601=33120FFF;08000701=33120FFF;08000801=33120FFF;09000101=000000FF;09000201=521D19FF;09000301=521D19FF;09000401=521D19FF;09000501=521D19FF;09000601=521D19FF;09000701=521D19FF;09000801=521D19FF;10000101=000000FF;10000201=33120FFF;10000301=33120FFF;10000401=33120FFF;10000501=33120FFF;10000601=33120FFF;10000701=33120FFF;10000801=33120FFF;11000101=000000FF;11000201=251C0BFF;11000301=251C0BFF;11000401=251C0BFF;11000501=251C0BFF;11000601=251C0BFF;11000701=251C0BFF;11000801=251C0BFF;12000101=000000FF;12000201=6D6330FF;12000301=6D6330FF;12000401=6D6330FF;12000501=6D6330FF;12000601=6D6330FF;12000701=6D6330FF;12000801=6D6330FF;13000101=000000FF;13000201=000000FF;13000301=000000FF;13000401=000000FF;13000501=000000FF;13000601=000000FF;13000701=000000FF;13000801=000000FF?blendmult=/objects/outpost/customsign/signplaceholder.png;0;-8?replace;01000101=000000FF;01000201=000000FF;01000301=000000FF;01000401=000000FF;01000501=000000FF;01000601=000000FF;01000701=000000FF;01000801=000000FF;02000101=403316FF;02000201=463818FF;02000301=463818FF;02000401=403316FF;02000501=403316FF;02000601=6D6330FF;02000701=6D6330FF;02000801=897C4CFF;03000101=403316FF;03000201=403316FF;03000301=403316FF;03000401=463818FF;03000501=463818FF;03000601=6D6330FF;03000701=6D6330FF;03000801=897C4CFF;04000101=463818FF;04000201=463818FF;04000301=403316FF;04000401=463818FF;04000501=463818FF;04000601=6D6330FF;04000701=897C4CFF;04000801=897C4CFF;05000101=251C0BFF;05000201=251C0BFF;05000301=251C0BFF;05000401=251C0BFF;05000501=251C0BFF;05000601=6D6330FF;05000701=897C4CFF;05000801=897C4CFF;06000101=33120FFF;06000201=33120FFF;06000301=554E4EFF;06000401=61686CFF;06000501=251C0BFF;06000601=6D6330FF;06000701=897C4CFF;06000801=897C4CFF;07000101=521D19FF;07000201=521D19FF;07000301=554E4EFF;07000401=61686CFF;07000501=251C0BFF;07000601=6D6330FF;07000701=897C4CFF;07000801=897C4CFF;08000101=33120FFF;08000201=33120FFF;08000301=554E4EFF;08000401=61686CFF;08000501=251C0BFF;08000601=6D6330FF;08000701=897C4CFF;08000801=897C4CFF;09000101=521D19FF;09000201=521D19FF;09000301=554E4EFF;09000401=61686CFF;09000501=251C0BFF;09000601=6D6330FF;09000701=897C4CFF;09000801=897C4CFF;10000101=33120FFF;10000201=33120FFF;10000301=554E4EFF;10000401=61686CFF;10000501=251C0BFF;10000601=6D6330FF;10000701=6D6330FF;10000801=897C4CFF;11000101=251C0BFF;11000201=251C0BFF;11000301=251C0BFF;11000401=251C0BFF;11000501=251C0BFF;11000601=6D6330FF;11000701=6D6330FF;11000801=897C4CFF;12000101=6D6330FF;12000201=6D6330FF;12000301=6D6330FF;12000401=6D6330FF;12000501=6D6330FF;12000601=6D6330FF;12000701=6D6330FF;12000801=6D6330FF;13000101=000000FF;13000201=000000FF;13000301=000000FF;13000401=000000FF;13000501=000000FF;13000601=000000FF;13000701=000000FF;13000801=000000FF?blendmult=/objects/outpost/customsign/signplaceholder.png;0;-16?replace;01000101=000000FF;02000101=000000FF;03000101=000000FF;04000101=000000FF;05000101=000000FF;06000101=000000FF;07000101=000000FF;08000101=000000FF;09000101=000000FF;10000101=000000FF;11000101=000000FF;12000101=000000FF;13000101=000000FF" })

  table.insert(item.parameters.inventoryIcon, { position = {16, 0}, image = "/objects/generic/mannequin/mannequin.png" })

  if not config.encrypt.name and not config.encrypt.directives then
    local inventoryFrames = {}

    if oldHead then
      local cfg = root.itemConfig(oldHead.name)
      local frames = cfg.config.maleFrames or cfg.config.femaleFrames or cfg.config.frames
      if frames then
        inventoryFrames[5] = { image = cfg.directory .. frames .. ":normal" .. (oldHead.parameters and oldHead.parameters.directives or ""), position = {16, 0} }
      end
    end

    if oldChest then
      local cfg = root.itemConfig(oldChest.name)
      local frames = cfg.config.maleFrames or cfg.config.femaleFrames or cfg.config.frames
      if frames then
        if frames.backSleeve then
          inventoryFrames[1] = { image = cfg.directory .. frames.backSleeve .. ":idle.1" .. (oldChest.parameters and oldChest.parameters.directives or ""), position = {16, 0} }
        end
        if frames.body then
          inventoryFrames[4] = { image = cfg.directory .. frames.body .. ":idle.1" .. (oldChest.parameters and oldChest.parameters.directives or ""), position = {16, 0} }
        end
        if frames.frontSleeve then
          inventoryFrames[6] = { image = cfg.directory .. frames.frontSleeve .. ":idle.1" .. (oldChest.parameters and oldChest.parameters.directives or ""), position = {16, 0} }
        end
      end
    end

    if oldLegs then
      local cfg = root.itemConfig(oldLegs.name)
      local frames = cfg.config.maleFrames or cfg.config.femaleFrames or cfg.config.frames
      if frames then
        inventoryFrames[3] = { image = cfg.directory .. frames .. ":idle.1" .. (oldLegs.parameters and oldLegs.parameters.directives or ""), position = {16, 0} }
      end
    end

    if oldBack then
      local cfg = root.itemConfig(oldLegs.name)
      local frames = cfg.config.maleFrames or cfg.config.femaleFrames or cfg.config.frames
      if frames then
        inventoryFrames[2] = { image = cfg.directory .. frames .. ":idle.1" .. (oldBack.parameters and oldBack.parameters.directives or ""), position = {16, 0} }
      end
    end

    for i=1,6 do
      local frame = inventoryFrames[i]
      if frame then table.insert(item.parameters.inventoryIcon, frame) end
    end
    if #item.parameters.inventoryIcon == 2 then
      table.remove(item.parameters.inventoryIcon, 2)
    end
  end

  -- Encrypt
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
