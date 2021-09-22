--[[-------------------------------------------------------------------------
	2019.12.24 ggram -- Gluegram wrapper, based on botgram
	botgram  https://github.com/botgram/botgram
	gluegram https://github.com/TRIGONIM/gluegram

	DEPENDENCIES
	- lua deferred https://github.com/zserge/lua-promises
	- Gmod's :Split, table.Add, http.Post, file structure

	2020.04.12 нашел в себе силы продолжить работу. До этого была написана только база
	2021.02.13 поддержка предшественника (gluegram) на моем сервере закончена
	2021.09.12 внедрение подобия middleware для улучшения контроля процессов. Теперь порядок имеет значение
	2021.09.14 раскидал содержимое по файлам. Теперь это не сингл файл
---------------------------------------------------------------------------]]


ggram = ggram or setmetatable({}, {__call = function(self, token) return self.bot(token) end})

function ggram.include(path)
	return include("ggram/includes/" .. path .. ".lua")
end

local BOT_MT = include("ggram/bot.lua")

function ggram.bot(token)
	local bot = setmetatable({
		token = token,
		id    = tonumber(token:match("^(%d+)")),

		handlers      = {}, -- index > bucket
		handler_index = {}, -- uid > index
	}, BOT_MT)

	return bot
end

deferred = deferred or ggram.include("deferred")
