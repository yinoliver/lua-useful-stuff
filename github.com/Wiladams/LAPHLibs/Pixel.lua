
--[[
	This file contains various pixel representations.
	There are parameterized types for each of the pixel 
	representations, and then there are instances of these
	types based on using 'uint8_t' as the base type.

	In most cases, you can just use the common uint8_t based
	types, but if you want to create your own, using uint16_t
	for example, the various parameterized types will help you.

	The types do have metatypes, which are intended to be fairly
	minimalist.

	The metatypes return the number of elements in the type
	and have a simple 'tostring()' function for easy debugging.

	Some other additions might be for convenient constructors, 
	which can be implemented using the '__new()' metamethod.
--]]

local ffi = require ("ffi")
local c99 = require ("c99_types")


-- Luminance
local Lum_t = function(ct)
	return ffi.typeof("struct { $ Lum;}", ct)
end

local Lum_mt = {
	__len = function(self) return 1 end,

	__tostring = function(self)
		return string.format("%d", self.Lum);
	end,

}

-- Luminance, with an Alpha channel
local LumAlpha_t = function(ct)
	return ffi.typeof("struct { $ Lum, Alpha;}", ct)
end

local LumAlpha_mt = {
	__len = function(self) return 2 end,
	
	__tostring = function(self)
		return string.format("%d, %d, %d", self.Lum, self.Alpha);
	end,

}


-- RGB
local RGB_t = function(ct)
	return ffi.typeof("struct { $ Red, Green, Blue;}", ct)
end

local RGB_mt = {
	__len = function(self) return 3 end,

	__tostring = function(self)
		return string.format("%d, %d, %d", self.Red, self.Green, self.Blue);
	end,

}


-- RGB, with Alpha channel
local RGBA_t = function(ct)
	return ffi.typeof("struct { $ Red, Green, Blue, Alpha;}", ct)
end

local RGBA_mt = {
	__len = function(self) return 4 end,

	__tostring = function(self)
		return string.format("%d, %d, %d, %d", self.Red, self.Green, self.Blue, self.Alpha);
	end,
}


-- BGR
local BGR_t = function(ct)
	return ffi.typeof("struct { $ Blue, Green, Red;}", ct)
end

local BGR_mt = {
	__len = function(self) return 3 end,

	__tostring = function(self)
		return string.format("%d, %d, %d, %d", self.Blue, self.Green, self.Red);
	end,
}

-- BGR, with Alpha channel
local BGRA_t = function(ct)
	return ffi.typeof("struct { $ Blue, Green, Red;}", ct)
end

local BGRA_mt = {
	__len = function(self) 
		return 4 
	end,

	__tostring = function(self)
		return string.format("%d, %d, %d, %d", self.Blue, self.Green, self.Red, self.Alpha);
	end,
}


-- Concrete type instances based on 'uint8_t' as the component type
local Lumb = ffi.metatype(Lum_t(c99.uint8_t), Lum_mt);
local LumAlphab = ffi.metatype(LumAlpha_t(c99.uint8_t), LumAlpha_mt);
	
local RGBb = ffi.metatype(RGB_t(c99.uint8_t), RGB_mt);
local RGBAb = ffi.metatype(RGBA_t(c99.uint8_t), RGBA_mt);

local BGRb = ffi.metatype(BGR_t(c99.uint8_t), BGR_mt);
local BGRAb = ffi.metatype(BGRA_t(c99.uint8_t), BGRA_mt);



return {
	Lum = Lumb,
	Lum_t = Lum_t,
	Lum_v = c99.array_tv(Lumb),
	Lum_p = c99.pointer_t(Lumb),

	LumA = LumAlphab,
	LumA_t = LumAlpha_t,
	LumA_v = c99.array_tv(LumAlphab),
	LumA_p = c99.pointer_t(LumAlphab),

	RGB = RGBb,
	RGB_t = RGB_t,
	RGB_v = c99.array_tv(RGBb),
	RGB_p = c99.pointer_t(RGBb),

	RGBA = RGBAb,
	RGBA_t = RGBA_t,
	RGBA_v = c99.array_tv(RGBAb),
	RGBA_p = c99.pointer_t(RGBAb),

	BGR = BGRb,
	BGR_t = BGR_t,
	BGR_v = c99.array_tv(BGRb),
	BGR_p = c99.pointer_t(BGRb),

	BGRA = BGRAb,
	BGRA_t = BGRA_t,
	BGRA_v = c99.array_tv(BGRAb),
	BGRA_p = c99.pointer_t(BGRAb),
}

