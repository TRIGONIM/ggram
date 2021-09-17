local BOT_MT = FindMetaTable("GG_BOT")

local function getUpdates(bot, parameters)
	return bot.call_method("getUpdates", parameters)
end

local function deferred_sleep(time)
	local d = deferred.new()
	timer.Simple(time, function() d:resolve() end)
	return d
end

local function log(msg, ...)
	if log_fi then
		log_fi(msg, ...)
	elseif GG_POLL_LOG then
		PrintTable({msg = msg, args = {...}})
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
			bot.handle_update(upd)
		end
	end)
end

function BOT_MT:enable_polling()
	self.polling = true
	log("enable_polling")

	-- http.Fetch after restart issue
	deferred_sleep(0):next(function()
		return poll(self)
	end):next(nil, function(err)
		if err.error_code == 409 then
			if err.description:match("terminated by other getUpdates") then log("terminated") error("terminated") end

			log("Deleting webhook")
			return self.call_method("deleteWebhook", {}) -- #todo What if there is rejection here?
		else
			local wait = err.parameters and err.parameters.retry_after or 5
			log("err. Waiting {} sec", wait)
			return deferred_sleep(wait)
		end
	end):next(function()
		log("restart polling")
		self:enable_polling()
	end, error)
end


-- INFUS_BOT.call_method("deleteWebhook", {}):next(PRINT, PRINT)
-- poll(INFUS_BOT)
-- INFUS_BOT.enable_polling()
-- INFUS_BOT.polling = false