local copas = require("copas")
local ht    = require("copas.http")

local parseRequest = ht.parseRequest
local request_orig = ht.request

-- override for ability to set headers
-- https://github.com/lunarmodules/copas/blob/master/src/copas/http.lua#L397
local function do_request(url, body, extra_headers_, method_, timeout_)
	local reqt = parseRequest(url, body)
	reqt.headers = reqt.headers or {}
	for k,v in pairs(extra_headers_ or {}) do
		reqt.headers[k] = v
	end

	reqt.method = method_ or reqt.method -- POST, GET, HEAD, PUT, DELETE, etc.

	reqt.timeout = timeout_ or reqt.timeout
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

ht.USERAGENT = "lua-requests-async"

local http = {}

local function string_URLEncode(str)
	return string.gsub(string.gsub(str, "\n", "\r\n"), "([^%w.])", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
end

function http.build_query(tParams)
	local kvs = {}
	for k, v in pairs(tParams) do
		table.insert(kvs, k .. "=" .. string_URLEncode( tostring(v) ))
	end
	return table.concat(kvs, "&")
end

-- docs below
function http.sync_request(parameters)
	assert(parameters.url, "url required")

	-- гмод лимитит хедеры и создал такой параметр.
	-- За пределами гмода не нужно, но для совместимости надо
	parameters.headers = parameters.headers or {}
	parameters.headers["content-type"] = parameters.headers["content-type"] or parameters.type or "text/plain; charset=utf-8"

	-- особенность POST. Для совпадения с гмодом
	if parameters.method == "POST" and parameters.parameters then
		parameters.headers["content-type"] = "application/x-www-form-urlencoded"
		parameters.body = http.build_query(parameters.parameters)
		parameters.parameters = nil
	end

	local paramss = parameters.parameters and http.build_query(parameters.parameters)
	local url = parameters.url .. (paramss and "?" .. paramss or "")
	parameters.fullurl = url

	local res, code, headers = do_request(url, parameters.body, parameters.headers, parameters.method, parameters.timeout)

	-- in case of errors: "timeout" or err str instead of code
	return res, code, headers
end

-- https://wiki.facepunch.com/gmod/Global.HTTP
-- f failed, f success, s method, s url, t parameters
-- t headers, s body (for POST), s type, i timeout
function http.request(parameters)
	return copas.addnamedthread("http_request", function(r, b, h)
		copas.setErrorHandler(function(msg, co, skt)
			if parameters.failed then
				local suberror = tostring(msg):match("TLS/SSL handshake failed: (.*)$") or tostring(msg) -- closed/System error/{}
				parameters.failed("copas_error:" .. suberror) -- can be parsed if needed
			end
		end)

		local res, code, headers = http.sync_request(parameters)
		if res and parameters.success then
			local ok, err = pcall(parameters.success, code, res, headers)
			if not ok then
				print(debug.traceback("HTTP Error In The Success Callback\n\t" .. err))
			end
		elseif not res and parameters.failed then
			local ok, err = pcall(parameters.failed, code) -- err str instead of code
			if not ok then
				print(debug.traceback("HTTP Error In The Failed Callback\n\t" .. err))
			end
		end
	end)
end

function http.get(url, onSuccess, onFailure, headers) -- analog gmod's http.Fetch
	http.request({
		url     = url,
		success = onSuccess and function(c, r, h) onSuccess(r, #r, h, c) end,
		failed  = onFailure,
		headers = headers,
	})
end

function http.post(url, params, onSuccess, onFailure, headers) -- analog http.Post
	http.request({
		url        = url,
		method     = "POST", -- post with parameters sends body as form-urlencoded
		parameters = params,
		success    = onSuccess and function(c, r, h) onSuccess(r, #r, h, c) end,
		failed     = onFailure,
		headers    = headers,
	})
end

-- http.post("http://httpbin.org/post", {
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

-- http.get("http://httpbin.org/get", function(body, len, headers, code)
-- 	print("body", body)
-- 	print("len", len)
-- 	print("code", code)

-- 	print("headers:")
-- 	for k,v in pairs(headers) do
-- 		print(k,v)
-- 	end
-- end, function(err)
-- 	print("err", err)
-- end, {["User-Agenture"] = "agent"})




-- while 1 do copas.step() end
-- copas.loop()

return http
