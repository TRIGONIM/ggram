-- local log_error = require("ggram.helpers.log_error")
-- log_error(token, method, parameters, err)

-- #todo ggram.json_encode, ggram.json_decode (used within too many files)
local util_TableToJSON = util and util.TableToJSON or require("gmod.util").TableToJSON

local do_log = function(sErr)
	local msg = ""
	msg = msg .. "==== " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===="
	msg = msg .. "\n" .. sErr
	msg = msg .. "\n========= [TLG ERR] =========\n\n"

	print(msg)
	-- debug.Trace() -- require("gmenv.debug") -- init
end

return function(token, method, parameters, err)
	local bot_id = token:match("^(%d+):") -- str num

	local sErr = string.format("BOT ID: %s\n%s %i\n%s\n\n%s",
		bot_id or token, method, err.error_code, err.description,
		util_TableToJSON(parameters))

	if err.extra then
		sErr = sErr .. "\n\nExtra: " .. util_TableToJSON(err.extra)
	end

	do_log(sErr)
end
