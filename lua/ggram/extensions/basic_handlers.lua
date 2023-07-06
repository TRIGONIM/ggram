local BOT_MT = require("ggram").include("bot")

function BOT_MT:update(handler, uid)
	return self.on(function()
		return true
	end, handler, "update_" .. uid)
end

function BOT_MT:command(name, handler)
	return self.on(function(ctx)
		return ctx.command == name
	end, handler, "command_" .. name)
end

function BOT_MT:callback(handler, uid) -- inline buttons pressed
	return self.on(function(ctx)
		return ctx.callback_query ~= nil
	end, handler, "callback_" .. uid)
end

function BOT_MT:text(handler, uid) -- not gif, not callback etc
	return self.on(function(ctx)
		return ctx.text ~= nil
	end, handler, "text_" .. uid)
end

function BOT_MT:message(handler, uid) -- commands, gifs, etc
	return self.on(function(ctx)
		return ctx.message ~= nil
	end, handler, "message_" .. uid)
end
