-- EXCLUSIVELY FOR GARRY'S MOD COMPATIBILITY
-- Ignore it if you plan to use it in pure lua. This file will not be used

-- This file should be shared for loading prior to SERVER
-- If it is loaded late, ggram-dependent scripts give errors
if CLIENT then return end

local function loadBots(path, iDeep)
	iDeep = iDeep or 0

	local files,dirs = file.Find(path .. "/*","LUA")
	for _,f in ipairs(files) do
		if f == "_init.lua" then
			print("GG Loading Bot " .. path)
			include(path .. "/" .. f)
			break
		end
	end

	for _,d in ipairs(iDeep > 0 and dirs or {}) do
		loadBots(path .. "/" .. d, iDeep - 1)
	end
end

local function loadExtensions(path)
	local files = file.Find(path .. "/*","LUA")
	for _,f in ipairs(files) do
		local fpath = path .. "/" .. f
		print("GG Loading " .. fpath)
		include(fpath)
	end
end


include("ggram/core.lua")
loadExtensions("ggram/extensions")
loadBots("ggram/bots", 1)
