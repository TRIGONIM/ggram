-- Чертов файл должен быть шаредным, так как шаред грузится до SERVER
-- А если грузиться поздно, то скрипты, зависимые от ggram, эррорят

if CLIENT then return end

local function loadBots(path, iDeep)
	iDeep = iDeep or 0

	local files,dirs = file.Find(path .. "/*","LUA")
	for _,f in ipairs(files) do
		if f == "_init.lua" then
			print("GG загрузка бота " .. path)
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
		print("GG загрузка " .. fpath)
		include(fpath)
	end
end


include("ggram/core.lua")
loadExtensions("ggram/extensions")
loadBots("ggram/bots", 1)
