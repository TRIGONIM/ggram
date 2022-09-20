local BOT_MT = debug.getregistry().GG_BOT

local function getUpdates(bot, parameters)
	return bot.call_method("getUpdates", parameters)
end

local function log(msg, ...)
	if not GG_POLL_LOG then return end

	if log_fi then
		log_fi(msg, ...)
	else
		print(msg, table.concat({...}, ", "))
	end
end

local function poll(bot)
	local key = "gg:polling_offset:" .. bot.id
	local offset = cookie.GetNumber(key)
	log("poll offset {}", offset or "none")
	return getUpdates(bot, {
		timeout = 30,
		offset = offset,
	}):next(function(updates)
		if bot.polling == false then return end -- external interference
		log("Received {} updates", #updates)

		if updates[1] then
			log("Last ID: {}", #updates, updates[#updates].update_id)
			cookie.Set(key, updates[#updates].update_id + 1)
		end

		for _,upd in ipairs(updates) do
			local ok, res = pcall(bot.handle_update, upd)
			if not ok then
				log("Error handling update: {}", res)
			end
		end
	end)
end

function BOT_MT:enable_polling()
	self.polling = true
	log("enable_polling")

	-- http.Fetch after restart issue
	deferred.sleep(0):next(function()
		return poll(self)
	end):next(nil, function(err)
		log("err after poll(self): {}", err)
		if err.error_code == 409 then
			if err.description:match("terminated by other getUpdates") then log("terminated") error("terminated") end

			log("Deleting webhook")
			return self.call_method("deleteWebhook", {}) -- #todo What if there is rejection here?
		else
			local wait = err.parameters and err.parameters.retry_after or 5
			log("err. Waiting {} sec", wait)
			return deferred.sleep(wait)
		end
	end):next(function()
		log("restart polling")
		self:enable_polling()
	end, error)
end


-- INFUS_BOT.call_method("deleteWebhook", {}):next(PrintTable, print)
-- poll(INFUS_BOT)
-- INFUS_BOT.enable_polling()
-- INFUS_BOT.polling = false
