--[[-------------------------------------------------------------------------
	Middleware that logs any received updates to specific file

	#TODO: fix middleware for pure-lua usage

	Example:
	bot.update(require("ggram.middlewares.logger"), "logger_middleware")
---------------------------------------------------------------------------]]

file.CreateDir("ggram/logs")
local function logJsonToFile(UPD, logfilename)
	local dtime, json = os.date("%Y-%m-%d %H:%M:%S"), util.TableToJSON(UPD)
	file.Append("ggram/logs/" .. logfilename .. ".txt", ("[%s] %s\n"):format(dtime,json))
end

return function(ctx)
	local uid = ctx.bot.username or ctx.bot.id
	logJsonToFile(ctx.update, uid)
end
