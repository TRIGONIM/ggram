local ver = "cvs"
local rev = "1"

package = "ggram"
version = ver .. "-" .. rev

local cvs = ver == "cvs"

source = {
	url = "git+https://github.com/TRIGONIM/ggram.git",
	branch = cvs and "master" or nil,
	tag = not cvs and ver or nil,
}
description = {
	summary = "ggram – Telegram Bot Framework",
	detailed = "Create Telegram bots of any complexity in pure Lua. Inspired by botgram.js",
	homepage = "https://github.com/TRIGONIM/ggram",
	license = "MIT",
	maintainer = "_AMD_ <amd@default.im>"
}
supported_platforms = { "linux", "macosx", "unix", "bsd" }
dependencies = { "lua >= 5.1, < 5.4", "copas", "luasec", "dkjson" }
build = {
	type = "builtin",
	modules = {
		["ggram.core"] = "lua/ggram/core.lua",
		["ggram.extensions.default_handlers"] = "lua/ggram/extensions/default_handlers.lua",
		["ggram.extensions.polling"] = "lua/ggram/extensions/polling.lua",
		["ggram.glua"] = "lua/ggram/glua/init.lua",
		["ggram.glua.http_async"] = "lua/ggram/glua/http_async.lua",
		["ggram.glua.json"] = "lua/ggram/glua/json.lua",
		["ggram.includes.core.bot"] = "lua/ggram/includes/core/bot.lua",
		["ggram.includes.core.deferred"] = "lua/ggram/includes/core/deferred.lua",
		["ggram.includes.core.log_error"] = "lua/ggram/includes/core/log_error.lua",
		["ggram.includes.core.reply"] = "lua/ggram/includes/core/reply.lua",
		["ggram.includes.core.request"] = "lua/ggram/includes/core/request.lua",
		["ggram.includes.extend_callback"] = "lua/ggram/includes/extend_callback.lua",
		["ggram.includes.extend_message"] = "lua/ggram/includes/extend_message.lua",
		["ggram.includes.logger"] = "lua/ggram/includes/logger.lua",
		["ggram.includes.session"] = "lua/ggram/includes/session.lua"
	}
}
