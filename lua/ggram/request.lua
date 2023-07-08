
local deferred         = deferred or require("deferred")
local HTTP             = HTTP or require("gmod.globals").HTTP -- https://github.com/TRIGONIM/lua-requests-async
local util_TableToJSON = (util or require("gmod.util")).TableToJSON
local util_JSONToTable = (util or require("gmod.util")).JSONToTable

local format_parameters = function(parameters)
	local params = {}
	for k,v in pairs(parameters) do
		if type(v) == "number" or type(v) == "boolean" then -- chat_id
			v = tostring(v)
		elseif type(v) == "table" then -- reply_markup
			v = util_TableToJSON(v)
		end
		params[k] = v
	end
	return params
end

local request = function(token, method, parameters_, http_struct_overrides_, base_url_)
	local d = deferred.new()

	local params = parameters_ and format_parameters(parameters_)

	local base_url = base_url_ or "https://api.telegram.org"
	local HTTPRequest = {
		url     = base_url .. "/bot" .. token .. "/" .. method,
		failed  = function(err_desc)
			d:reject({error_code = 500, description = "http_error", extra = {http_error = err_desc}})
		end,
		success = function(http_code, json)
			local dat = util_JSONToTable(json)
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

	for key,val in pairs(http_struct_overrides_ or {}) do
		HTTPRequest[key] = val
	end

	HTTP(HTTPRequest)

	return d
end

local exports = {}

exports.request = request
exports.format_parameters = format_parameters

return exports
