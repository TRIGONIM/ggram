-- local log_error = ggram.include("core/log_error")
-- log_error(token, method, parameters, err)


local do_log = function(sErr)
	local msg = ""
	msg = msg .. "==== " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===="
	msg = msg .. "\n" .. sErr
	msg = msg .. "\n========= [TLG ERR] =========\n\n"

	print(msg)
	-- debug.Trace()
end

return function(token, method, parameters, err)
	local bot_id = token:match("^(%d+):") -- str num

	local sErr = string.format("BOT ID: %s\n%s %i\n%s\n\n%s",
		bot_id or token, method, err.error_code, err.description,
		util.TableToJSON(parameters))

	if err.extra then
		sErr = sErr .. "\n\nExtra: " .. util.TableToJSON(err.extra)
	end

	do_log(sErr)
end
