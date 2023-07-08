-- local log_error = require("ggram.helpers.log_error")
-- log_error(token, method, parameters, err)

local json_encode = (util or require("gmod.util")).TableToJSON
-- local debug_Trace = require("gmod.debug").Trace

local do_log = function(sErr)
	local msg = ""
	msg = msg .. "==== " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===="
	msg = msg .. "\n" .. sErr
	msg = msg .. "\n========= [TLG ERR] =========\n\n"

	print(msg)
	-- debug_Trace()
end

return function(token, method, parameters, err)
	local bot_id = token:match("^(%d+):") -- str num

	local sErr = string.format("BOT ID: %s\n%s %i\n%s\n\n%s",
		bot_id or token, method, err.error_code, err.description,
		json_encode(parameters))

	if err.extra then
		sErr = sErr .. "\n\nExtra: " .. json_encode(err.extra)
	end

	do_log(sErr)
end
