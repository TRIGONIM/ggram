--[[-------------------------------------------------------------------------
	2019.12.24 ggram -- Gluegram wrapper, based on botgram
	2020.04.12 нашел в себе силы продолжить работу. До этого была написана только база
	2021.02.13 поддержка предшественника (gluegram) на моем сервере закончена
	2021.09.12 внедрение подобия middleware для улучшения контроля процессов. Теперь порядок имеет значение
	2021.09.14 раскидал содержимое по файлам. Теперь это не сингл файл
	2022.04.15 сделал возможным использование в чистом Lua, вне пределов гмода (copas, luasocket)

	Inspired by:
	botgram  https://github.com/botgram/botgram
---------------------------------------------------------------------------]]

GARRYSMOD = RunStringEx ~= nil

if not GARRYSMOD then
	require("ggram.glua")
end


ggram = ggram or setmetatable({}, {__call = function(self, ...) return self.bot(...) end})

function ggram.include(path)
	return include("ggram/includes/" .. path .. ".lua")
end

local BOT_MT = ggram.include("core/bot")
function ggram.bot(token, options_)
	local bot = setmetatable({
		token = token,
		id    = tonumber(token:match("^(%d+)")),

		handlers      = {}, -- index > bucket
		handler_index = {}, -- uid > index

		options = options_ or {
			base_url = "https://api.telegram.org"
		},
	}, BOT_MT)

	return bot
end

deferred = deferred or ggram.include("core/deferred")


-- In garrysmod, this loads automatically
if not GARRYSMOD then
	include("ggram/extensions/default_handlers.lua")
	include("ggram/extensions/polling.lua")
end

