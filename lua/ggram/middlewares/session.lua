-- example:
-- https://img.qweqwe.ovh/1631502020622.jpg

local json_encode = require("gmod.util").TableToJSON
local json_decode = require("gmod.util").JSONToTable

local function resolve_message(ctx)
	return
		ctx.message or
		(ctx.callback_query and ctx.callback_query.message) or
		ctx.edited_message or
		ctx.channel_post or
		ctx.edited_channel_post
end

-- local function resolve_chat(ctx) -- в ядро, как мидл для ctx.chat? #todo
-- 	local src = ctx.update.chat_member or
-- 		ctx.update.my_chat_member or
-- 		resolve_message(ctx)

-- 	return src and src.chat
-- end

local function get_key(ctx)
	local msg = resolve_message(ctx)
	if msg and msg.from then
		return "gg:sessions:" .. msg.chat.id .. ":" .. msg.from.id
	end
end

return function(ctx)
	local key = get_key(ctx)
	if not key then return end

	if not ctx.bot.session_cache then
		ctx.bot.session_cache = setmetatable({}, {__mode = "kv"})
	end

	local tData = ctx.bot.session_cache[key] or json_decode(cookie.GetString(key, "[]"))
	ctx.bot.session_cache[key] = tData

	local SESSION = {_source = tData}
	ctx.session = setmetatable(SESSION, {
		__index = SESSION._source,
		__newindex = function(self, k, v)
			if self._source[k] == v then return end

			self._source[k] = v
			cookie.Set(key, json_encode(self._source))
		end
	})
end
