require "/scripts/arc4.lua"
require "/scripts/base64.lua"

--[[
  Simple wrapper for arc4 encryption and base64 encoding.

  Encryption:
  Arc4 will be used to encrypt given strings. Base64 will be used to encode the
  encrypted data, making it safe for storage.

  Decryption:
  Base64 will be used to decode the encoded and encrypted data. Arc4 will be
  used to decrypt the encrypted data.
]]

encryption = {}
encryption.keyPath = "storedOutfitsKey"

function encryption.getKey()
  local key = root.getConfigurationPath(encryption.keyPath)
  return key
end

function encryption.setKey(key)
  root.setConfigurationPath(encryption.keyPath, key)
end

function encryption.generateKey()
  math.randomseed(os.time())
  local key = ""
  for i=1,math.random(16,64) do
      key = key .. string.char(math.random(32,126))
  end
  encryption.setKey(key)
  return key
end

function encryption.encrypt(str, key)
  if not key then key = encryption.getKey() end

  local encoding = arcfour.new(key)
  arcfour.generate(encoding, 3072)

  local cipher = arcfour.cipher(encoding, str)
  local baseEncoded = base64.enc(cipher)

  return baseEncoded
end

function encryption.decrypt(str, key)
  if not key then key = encryption.getKey() end
  if type(key) ~= "string" then error("Attempted to decrypt data without a valid key!") end

  local decoding = arcfour.new(key)
  arcfour.generate(decoding, 3072)

  local cipher = base64.dec(str)
  local plain = arcfour.cipher(decoding, cipher)

  return plain
end
