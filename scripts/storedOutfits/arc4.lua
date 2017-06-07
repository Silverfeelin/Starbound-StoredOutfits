-- ARCFOUR implementation in pure Lua
-- Copyright 2008 Rob Kendrick <rjek@rjek.com>
-- Distributed under the MIT licence

-- Several small modifications have been made to the source script, to work with
-- Starbound. Only the function and table structure of the library has been
-- changed, together with the below sample usage.
-- You can find the original code here:
-- https://www.rjek.com/arcfour.lua.txt
--
--	enc_state = arcfour.new("My Encryption Key")
--	arcfour.generate(enc_state, 3072)
--	ciphertext = arcfour.cipher(enc_state, "Hello, world!")
--
--	dec_state = arcfour.new("My Encryption Key")
--	arcfour.generate(dec_state, 3072)
--	plaintext = arcfour.cipher(dec_state, ciphertext)
--
-- Best practise says to discard the first 3072 bytes from the generated
-- stream to avoid leaking information about the key.  Additionally, if using
-- a nonce, you should hash your key and nonce together, rather than
-- concatenating them.

arcfour = {}

-- Given a binary boolean function b(x,y) defined by a table
-- of four bits { b(0,0), b(0,1), b(1,0), b(1,1) },
-- return a 2D lookup table f[][] where f[x][y] is b() applied
-- bitwise to the lower eight bits of x and y.
function arcfour.make_byte_table(bits)
	local f = { }
	for i = 0, 255 do
		f[i] = { }
	end

	f[0][0] = bits[1] * 255

	local m = 1

	for k = 0, 7 do
		for i = 0, m - 1 do
			for j = 0, m - 1 do
				local fij = f[i][j] - bits[1] * m
				f[i  ][j+m] = fij + bits[2] * m
				f[i+m][j  ] = fij + bits[3] * m
				f[i+m][j+m] = fij + bits[4] * m
			end
		end
		m = m * 2
	end

	return f
end

local byte_xor = arcfour.make_byte_table { 0, 1, 1, 0 }

function arcfour.generate(self, count)
	local S, i, j = self.S, self.i, self.j
	local o = { }
	local char = string.char

	for z = 1, count do
		i = (i + 1) % 256
		j = (j + S[i]) % 256
		S[i], S[j] = S[j], S[i]
		o[z] = char(S[(S[i] + S[j]) % 256])
	end

	self.i, self.j = i, j
	return table.concat(o)
end

function arcfour.cipher(self, plaintext)
	local pad = arcfour.generate(self, #plaintext)
	local r = { }
	local byte = string.byte
	local char = string.char

	for i = 1, #plaintext do
		r[i] = char(byte_xor[byte(plaintext, i)][byte(pad, i)])
	end

	return table.concat(r)
end

function arcfour.schedule(self, key)
	local S = self.S
	local j, kz = 0, #key
	local byte = string.byte

	for i = 0, 255 do
		j = (j + S[i] + byte(key, (i % kz) + 1)) % 256;
		S[i], S[j] = S[j], S[i]
	end
end

function arcfour.new(key)
	local S = { }
	local r = {
		S = S, i = 0, j = 0,
		generate = arcfour.generate,
		cipher = arcfour.cipher,
		schedule = arcfour.schedule
	}

	for i = 0, 255 do
		S[i] = i
	end

	if key then
		arcfour.schedule(r, key)
	end

	return r
end
