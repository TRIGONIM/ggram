-- require("ggram.polling").start(bot)

local cookie = cookie or require("gmod.cookie")

local coro  = require("ggram.helpers.coro")

local coroutinize  = coro.coroutinize
local def_to_yield = coro.deferred_to_yield
local co_sleep     = coro.wait

local function co_call_method(bot, method, parameters)
	return def_to_yield( bot.call_method )(method, parameters)
end

local GG_POLL_LOG = false
local function log(msg, ...)
	if not GG_POLL_LOG then return end
	print(msg:format(...))
end

local process_updates = function(bot, updates)
	if #updates > 0 then
		local lastUpdate = updates[#updates]
		log("#updates: %d, Last ID: %s", #updates, lastUpdate.update_id)
		cookie.Set("gg:polling_offset:" .. bot.id, lastUpdate.update_id + 1)

		for _, update in ipairs(updates) do
			local success, result = pcall(bot.handle_update, update)
			if not success then
				log("Error handling update: %s", result)
			end
		end
	end
end

local co_poll = function(bot)
	local offset = cookie.GetNumber("gg:polling_offset:" .. bot.id)
	log("co_poll(bot) offset %s", offset or "none")
	return co_call_method(bot, "getUpdates", {timeout = 30, offset = offset})
end

local co_on_error = function(bot, err)
	log("err after co_poll(bot): %s", err)

	if err.error_code == 409 then
		if err.description:match("terminated by other getUpdates") then
			log("terminated")
			print("ggram: Polling stopped: " .. err.description)
			bot.polling = false
		else
			log("Deleting webhook")
			local ok = co_call_method(bot, "deleteWebhook", {})
			print(ok and "Webhook deleted" or "Webhook deletion error")
		end
	else
		local wait = err.parameters and err.parameters.retry_after or 5
		log("err. Waiting %d sec", wait)
		co_sleep(wait)
	end
end

local polling_loop = function(bot)
	while bot.polling do
		local ok, res_err = co_poll(bot)
		if not ok then
			co_on_error(bot, res_err)
		else
			log("Received %d updates", #res_err)
			process_updates(bot, res_err)
		end
	end
end

local polling = {}

polling.verbose = function(enabled)
	GG_POLL_LOG = enabled
end

polling.start = function(bot)
	log("call start(bot)")
	bot.polling = true

	coroutinize(function()
		co_sleep(0) -- for garry's mod (http not working at the first tick)
		def_to_yield( bot.identify )() -- bot:identify()
		polling_loop(bot)
	end)
end

return polling

-- GG_POLL_LOG = true
-- local ggram = require("ggram")
-- local bot = ggram( require("env").tg_test )
-- -- bot.call_method("deleteWebhook", {}):next(PRINT, PRINT)
-- polling.start(bot)
-- ggram.idle()

-- bot.text(function(ctx) ctx.reply.text(ctx.text) end, "asd")
-- bot.command("stop", function() bot.polling = false print("stopped") end)
