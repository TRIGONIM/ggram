local format_parameters = function(parameters)
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

local request = function(token, method, parameters, options_, base_url_)
	local d = deferred.new()

	local params = format_parameters(parameters)

	local base_url = base_url_ or "https://api.telegram.org"
	local HTTPRequest = {
		url     = base_url .. "/bot" .. token .. "/" .. method,
		failed  = function(err_desc)
			print("inside HTTPRequest.failed, err_desc = " .. err_desc)
			d:reject({error_code = 500, description = "http_error", extra = {http_error = err_desc}})
		end,
		success = function(http_code, json)
			print("inside HTTPRequest.success, http_code = " .. http_code)
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
		end,
		method = "POST",
		parameters = params,
	}

	for key,val in pairs(options_ or {}) do
		HTTPRequest[key] = val
	end

	print("inside request(token, '" .. method .. "', parameters, options_, base_url_)")

	HTTP(HTTPRequest)

	return d
end

local exports = {}

exports.request = request
exports.format_parameters = format_parameters

return exports
