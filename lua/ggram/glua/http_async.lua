local copas = require("copas")
local ht    = require("copas.http")

-- local ltn12 = require("ltn12")

local parseRequest = ht.parseRequest
local request_orig = ht.request

-- override for ability to set headers
-- https://github.com/lunarmodules/copas/blob/master/src/copas/http.lua#L397
local function request(url, body, extra_headers_, method_, timeout_)
	local reqt = parseRequest(url, body)
	reqt.headers = reqt.headers or {}
	for k,v in pairs(extra_headers_ or {}) do
		reqt.headers[k] = v
	end

	if method_ then -- override
		reqt.method = method_ -- POST, GET, HEAD, PUT, DELETE, etc.
	end

	if timeout_ then
		reqt.timeout = timeout_
	end

	-- reqt.timeout = 3

	-- reqt.protocol = "any"
	-- reqt.options = {"all", "no_sslv2", "no_sslv3", "no_tlsv1"}
	-- reqt.verify = "none"

	local ok, code, headers, status = request_orig(reqt)
	if ok then
		return table.concat(reqt.target), code, headers, status
	else
		return nil, code
	end
end

ht.USERAGENT = "ggram v0.1"

local http = {}

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

local handle_request_error = function(parameters, msg)
	parameters.try_ = parameters.try_ or 0
	parameters.try_ = parameters.try_ + 1

	if parameters.try_ < 3 then
		timer.Simple(3, function()
			http.request(parameters)
		end)
	elseif parameters.failed then
		parameters.failed("http_request_error: " .. msg)
	end
end

-- https://wiki.facepunch.com/gmod/Global.HTTP
-- f failed, f success, s method, s url, t parameters
-- t headers, s body (for POST), s type, i timeout
function http.request(parameters)
	return copas.addnamedthread("http_request", function(r, b, h)
		copas.setErrorHandler(function(msg, co, skt)
			handle_request_error(parameters, msg)
		end)

		-- гмод лимитит хедеры и создал такой параметр.
		-- За пределами гмода не нужно, но для совместимости надо
		parameters.headers = parameters.headers or {}
		if parameters.type then
			parameters.headers["content-type"] = parameters.type
		else
			parameters.headers["content-type"] = "text/plain; charset=utf-8" -- non-gmod env. friendly to json payload
		end

		-- особенность POST. Для совпадения с гмодом
		if parameters.method == "POST" and parameters.parameters then
			parameters.headers["content-type"] = "application/x-www-form-urlencoded"
			parameters.body = http.BuildQuery(parameters.parameters)
			parameters.parameters = nil
		end

		local paramss = parameters.parameters and http.BuildQuery(parameters.parameters)
		local url = parameters.url .. (paramss and "?" .. paramss or "")
		parameters.fullurl = url
		local res, code, headers = request(url, parameters.body, parameters.headers, parameters.method, parameters.timeout)
		-- assert(res, code)

		if not res and code == "timeout" then
			handle_request_error(parameters, code)
			return
		end

		if res and parameters.success then
			-- pcall, чтобы copas.setErrorHandler не ловил ошибки, допущенные в обработчике
			-- function(json) print(3 + "abc") end
			local ok, err = pcall(parameters.success, code, res, headers)
			if not ok then
				print(debug.traceback("HTTP Error In The Success Callback\n\t" .. err))
			end
			-- parameters.success(code, res, headers)
		elseif not res and parameters.failed then
			local ok, err = pcall(parameters.failed, code)
			if not ok then
				print(debug.traceback("HTTP Error In The Failed Callback\n\t" .. err))
			end
			-- parameters.failed(code)
		end
	end)
end

function http.Fetch(url, onSuccess, onFailure, headers)
	http.request({
		url = url,
		success = onSuccess and function(c, r, h) onSuccess(r, #r, h, c) end,
		failed = onFailure,
		headers = headers,
	})
end

function http.Post(url, params, onSuccess, onFailure, headers)
	http.request({
		url = url,
		method = "POST", -- post with parameters sends body as form-urlencoded
		parameters = params,
		success = onSuccess and function(c, r, h) onSuccess(r, #r, h, c) end,
		failed = onFailure,
		headers = headers,
	})
end

-- http.Post("http://httpbin.org/post", {
-- 	param1 = "value1",
-- 	param2 = "value2",
-- }, function(body, len, headers, code)
-- 	print("body:", body)
-- 	-- PrintTable({
-- 	-- 	len = len,
-- 	-- 	headers = headers,
-- 	-- 	code = code,
-- 	-- })
-- end, function(err) print("post err", err) end, {headername = "value"})

-- http.Fetch("http://httpbin.org/get", function(body, len, headers, code)
-- 	print("body", body)
-- 	print("len", len)
-- 	print("code", code)

-- 	print("headers:")
-- 	for k,v in pairs(headers) do
-- 		print(k,v)
-- 	end
-- end, function(err)
-- 	print("err", err)
-- end, {["User-Agenture"] = "huipezka"})




-- while 1 do copas.step() end
-- copas.loop()

return http
