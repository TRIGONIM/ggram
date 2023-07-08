--[[-------------------------------------------------------------------------
	2019.12.24 ggram -- Gluegram wrapper, based on botgram
	2020.04.12 found the strength to continue the work. Before that, only the base had been written
	2021.02.13 support for the predecessor (gluegram) on my server is over
	2021.09.12 implementation of a semblance of middleware to improve process control. Now order matters
	2021.09.14 spread the content into files. Now it's not a single file
	2022.04.15 made it possible to use outside of Garry's Mod in pure lua (using copas, luasocket and some gmod deps)

	Inspired by:
	botgram  https://github.com/botgram/botgram
---------------------------------------------------------------------------]]

local GARRYSMOD = RunStringEx ~= nil

if not GARRYSMOD then
	require("glua")
end


local ggram = setmetatable({}, {__call = function(self, ...) return self.bot(...) end})

function ggram.include(path)
	return require("ggram." .. path)
end

function ggram.bot(token, options_)
	local bot = setmetatable({
		token = token,
		id    = tonumber(token:match("^(%d+)")),

		handlers      = {}, -- index > bucket
		handler_index = {}, -- uid > index

		options = options_ or {
			base_url = "https://api.telegram.org"
		},
	}, ggram.include("bot"))

	-- Должно быть после include("bot"), так как внутри хочет видеть BOT_MT
	ggram.include("extensions.basic_handlers")

	return bot
end

function ggram.idle()
	if not GARRYSMOD then
		local copas = require("copas")
		print("idling")
		while 1 do copas.step() end
	end
end

return ggram
