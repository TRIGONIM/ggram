-- #todo method = POST
-- body, headers, type

local copas = require("copas")
local ht    = require("copas.http")

-- local ltn12 = require("ltn12")

local request = ht.request
-- local parseReq = ht.parseRequest

ht.USERAGENT = "ggram v0.1"

http = {}

function string:URLEncode()
	return string.gsub(string.gsub(self, "\n", "\r\n"), "([^%w.])", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
end

-- function string:URLDecode()
-- 	return self:gsub("%%(%x%x)", function(hex)
-- 		return string.char(tonumber(hex, 16))
-- 	end)
-- end

function http.BuildQuery(tParams)
	local kvs = {}
	for k,v in pairs(tParams) do
		table.insert(kvs, k .. "=" .. tostring(v):URLEncode())
	end
	return table.concat(kvs, "&")
end

function HTTP(parameters)
	copas.addthread(function()
		ht.TIMEOUT = parameters.timeout or 60

		local paramss = parameters.parameters and http.BuildQuery(parameters.parameters)
		local url = parameters.url .. (paramss and "?" .. paramss or "")
		local res, code, headers = request(url)
		-- assert(res, code)

		if res and parameters.success then
			parameters.success(code, res, headers)
		elseif not res and parameters.failed then
			parameters.failed(code)
		end
	end)
end

-- function http.Fetch(url, onSuccess, onFailure, headers)
-- 	HTTP({
-- 		-- method = "GET",
-- 		url = url,
-- 		success = onSuccess and function(c, r, h) onSuccess(r, #r, h, c) end,
-- 		failed = onFailure,
-- 		-- headers = headers,
-- 		timeout = 60,

-- 		-- body = "",
-- 		-- type = "",
-- 	})
-- end


-- for i = 1,3 do
-- 	http.Fetch("https://httpbin.org/get", function(body, headers, code)
-- 		print("body", body)
-- 		print("code", code)

-- 		print("headers:")
-- 		for k,v in pairs(headers) do
-- 			print(k,v)
-- 		end
-- 	end, function(err)
-- 		print("err", err)
-- 	end)
-- end

-- copas.addthread(function()
-- 	while true do end
-- end)



-- while 1 do
--   copas.step()
-- end

-- copas.loop()
