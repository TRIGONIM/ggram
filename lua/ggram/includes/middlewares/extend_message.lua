--[[-------------------------------------------------------------------------
	Example for /cmd@name_bot a b c

	ctx.args() > {a, b, c}
	ctx.username > name_bot
	ctx.command > cmd

	ctx.mine determines if this command exactly for this bot or either
	ctx.exclusive 100% for me or another candidates are possible?
---------------------------------------------------------------------------]]

local function extract_args(argss)
	local tArgs = {}
	for _,arg in ipairs( argss:Split(" ") ) do
		if arg ~= "" then -- #todo нужно ли?
			tArgs[#tArgs + 1] = arg
		end
	end

	return tArgs
end

local function attach_command(ctx, ent)
	local msg = ctx.update.message
	local text = msg.text

	local start = ent.offset + 2
	local endd = start + ent.length - 2
	local psc = text:sub(start, endd):Split("@")
	local name = psc[1]:lower() -- /CMD@botname > cmd

	local argss = text:sub(endd + 2)
	ctx.args = function() return extract_args(argss) end
	ctx.username = psc[2]
	ctx.command = name

	if ctx.username then
		ctx.mine = ctx.bot.username and ctx.bot.username:lower() == ctx.username:lower()
		ctx.exclusive = ctx.mine
	else
		ctx.mine = true
		ctx.exclusive = msg.chat.type == "private"
	end
end

return function(ctx)
	if not ctx.update.message then return end

	local msg = ctx.update.message
	ctx.reply = ctx.bot.reply(msg.chat.id)

	for _,ent in ipairs(msg.entities or {}) do
		if ent.type == "bot_command" then
			attach_command(ctx, ent)
			break -- только первая, т.к. в аттаче присваивание сообщению команды и принадлежности
		end
	end
end
