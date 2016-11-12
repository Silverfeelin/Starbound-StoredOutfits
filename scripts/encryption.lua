--[[
  Simple wrapper for arc4 encryption and base64 encoding.

  Encryption:
  Arc4 will be used to encrypt given strings. Base64 will be used to encode the
  encrypted data, making it safe for storage.

  Decryption:
  Base64 will be used to decode the encoded and encrypted data. Arc4 will be
  used to decrypt the encrypted data.
]]

require "/scripts/arc4.lua"
require "/scripts/base64.lua"

encryption = {}
encryption.keyPath = "storedOutfitsKey"

--[[
  Returns the RC4 encryption key, found in the `starbound.config`.
  @return - Encryption key, or nil
]]
function encryption.getKey()
  local key = root.getConfigurationPath(encryption.keyPath)
  return key
end

--[[
  Sets the RC4 encryption key in the `starbound.config` file.
  @param key - Key to set. Should be a valid key string.
  @see encryption.generateKey
]]
function encryption.setKey(key)
  root.setConfigurationPath(encryption.keyPath, key)
end

--[[
  Generates and sets a new RC4 encryption key.
  Key can be between 5 and 256 random chars (byte value between 32 and 126).
  This function takes a random value between 16 and 64 for key length.
  @return - Generated key.
  @see encryption.setKey
]]
function encryption.generateKey()
  math.randomseed(os.time())
  local key = ""
  for i=1,math.random(16,64) do
      key = key .. string.char(math.random(32,126))
  end
  encryption.setKey(key)
  return key
end

--[[
  Encrypt the given string using RC4, then encode the encrypted data using
  base64.
  @param str - String to encrypt and encode.
  @param key - Key to use for RC4 encryption.
  @return - Encrypted and encoded string.
]]
function encryption.encrypt(str, key)
  if not key then key = encryption.getKey() end

  local encoding = arcfour.new(key)
  arcfour.generate(encoding, 3072)

  local cipher = arcfour.cipher(encoding, str)
  local baseEncoded = base64.enc(cipher)

  return baseEncoded
end

--[[
  Decode the given string using base64, then decrypt the encrypted data using
  RC4.
  @param str - String to decode and decrypt.
  @param key - Key used for RC4 encryption.
  @return - Decoded and decrypted string. Does not validate if key and output
    is correct.
]]
function encryption.decrypt(str, key)
  if not key then key = encryption.getKey() end
  if type(key) ~= "string" then error("Attempted to decrypt data without a valid key!") end

  local decoding = arcfour.new(key)
  arcfour.generate(decoding, 3072)

  local cipher = base64.dec(str)
  local plain = arcfour.cipher(decoding, cipher)

  return plain
end
