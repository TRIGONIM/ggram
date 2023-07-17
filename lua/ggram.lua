--- ggram - Telegram Bot Framework, written on Lua
---
--- Работает в Garry's Mod и в чистом Lua
---
--- git.io/ggram
-- @module ggram

local ggram = setmetatable({}, {__call = function(self, ...) return self.bot(...) end})

--- Создать объект бота. Вместо ggram.bot(...) можно писать ggram(...)
--- @function ggram
--- @tparam string token Токен бота. Получить можно тут: t.me/BotFather
--- @tparam[opt] table options available fields: base_url. default: https://api.telegram.org
--- @treturn Bot
function ggram.bot(token, options_)
	local bot = setmetatable({
		token = token,
		id    = tonumber(token:match("^(%d+)")),

		handlers      = {}, -- index > bucket
		handler_index = {}, -- uid > index

		options = options_ or {
			base_url = "https://api.telegram.org"
		},
	}, require("ggram.bot"))

	return bot
end

--- Запустить бесконечное выполнение кода.
---
--- В garry's mod не обязательно. В чистом луа без этого скрипт сразу завершится. Под "капотом" вызывает copas.loop()
--- @function idle
function ggram.idle()
	local ok, copas = pcall(require, "copas")
	if ok then
		print("idling")
		while true do copas.step() end
	end
end

return ggram
