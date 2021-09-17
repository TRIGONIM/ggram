local logError = function(sErr)
	local msg = ""
	msg = msg .. "==== " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===="
	msg = msg .. "\n" .. sErr
	msg = msg .. "\n========= [TLG ERR] =========\n\n"

	log_fe(msg)
	file.Append("ggram/logs/errors.txt", msg)
	-- debug.Trace()
end

local logRequestError = function(token, method, parameters, response)
	local bot_id = token:match("^(%d+):") -- str num

	local sErr = string.format("BOT ID: %s\n%s %i\n%s\n\n%s",
		bot_id or token, method, response.error_code, response.description,
		util.TableToJSON(parameters))

	if response.extra then
		sErr = sErr .. "\n\nExtra: " .. util.TableToJSON(response.extra)
	end

	logError(sErr)
end

local formatParameters = function(parameters)
	local params = {}
	for k,v in pairs(parameters) do
		if isnumber(v) or isbool(v) then -- chat_id
			v = tostring(v)
		elseif istable(v) then -- reply_markup
			v = util.TableToJSON(v)
		end
		params[k] = v
	end
	return params
end

return function(token, method, parameters)
	local d = deferred.new()

	local params = formatParameters(parameters)

	http.Post("https://api.telegram.org/bot" .. token .. "/" .. method, params,
		function(json, _, _, http_code)
			local dat = util.JSONToTable(json)
			if not dat then -- firewall?
				d:reject({error_code = 500, description = "no_json", extra = {body = json, http_code = http_code}})
				return
			end

			if dat.ok then
				d:resolve(dat.result)
			else
				d:reject(dat) -- error_code, description, opt parameters.retry_after
			end
		end, function(err_desc)
			d:reject({error_code = 500, description = "http_error", extra = {http_error = err_desc}})
		end
	)

	return d:next(nil, function(dat)
		logRequestError(token, method, parameters, dat)
		error(dat)
	end)
end
