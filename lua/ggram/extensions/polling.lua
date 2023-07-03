local BOT_MT = debug.getregistry().GG_BOT

local function getUpdates(bot, parameters)
	return bot.call_method("getUpdates", parameters)
end

local function log(msg, ...)
	if not GG_POLL_LOG then return end
	print(msg:format(...))
end

local function processUpdates(bot, updates)
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

local function poll(bot)
	local key = "gg:polling_offset:" .. bot.id
	local offset = cookie.GetNumber(key)
	log("poll offset %s", offset or "none")

	return getUpdates(bot, {timeout = 30, offset = offset})
		:next(function(updates)
			log("Received %d updates", #updates)
			processUpdates(bot, updates)
		end)
end

local function handlePollError(self, err)
	log("err after poll(self): %s", err)

	if err.error_code == 409 then
		if err.description:match("terminated by other getUpdates") then
			log("terminated")
			error("terminated")
		else
			log("Deleting webhook")
			return self.call_method("deleteWebhook", {})
		end
	else
		local wait = err.parameters and err.parameters.retry_after or 5
		log("err. Waiting %d sec", wait)
		return deferred.sleep(wait)
	end
end

function BOT_MT:enable_polling()
	self.polling = true
	log("enable_polling")

	local function restart_polling()
		if not self.polling then log("polling disabled") return end
		log("restart polling")
		self:enable_polling()
	end

	deferred.sleep(0)
		:next(function() return poll(self) end)
		:next(nil, function(err) return handlePollError(self, err) end)
		:next(restart_polling, error)
end

-- GG_POLL_LOG = true
-- local bot = ggram( require("env").test_bot )
-- bot.call_method("deleteWebhook", {}):next(PRINT, PRINT)
-- -- poll(bot)
-- bot.enable_polling()

-- bot.text(function(ctx) ctx.reply.text(ctx.text) end, "asd")
-- bot.command("stop", function() bot.polling = false print("stopped") end)
