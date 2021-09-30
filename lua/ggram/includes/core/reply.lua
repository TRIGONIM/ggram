--[[-------------------------------------------------------------------------
	MODEL
---------------------------------------------------------------------------]]
local function resolveMessage(msg)
	return tonumber(msg) or msg.message_id
end

local function resolveChat(chat)
	return tonumber(chat) or chat.id
end

local function resolveFile(file)
	local expr = (istable(file) and file.id) or (isstring(file) and file)
	return assert(expr, "Invalid file or file ID")
end


ggram.methods = ggram.methods or {}
local R = ggram.methods
function R:sendGeneric(method, additionalParameters)
	local parameters = table.Copy(self.parameters)
	self.parameters = {}

	parameters.chat_id = self.id
	for k,v in pairs(additionalParameters or {}) do -- merge
		parameters[k] = v
	end

	return self.bot.call_method(method, parameters)
end

-- *methods functions*
-- Не доделана https://github.com/botgram/botgram/blob/master/lib/reply.js#L128-L135
-- function R:forward(msg_id, chat_id)
-- 	return self.sendGeneric("forwardMessage", {message_id = resolveMessage(msg_id), from_chat_id = resolveChat(chat_id)})
-- end

function R:text(text, mode)
	return self.sendGeneric("sendMessage", {text = text, parse_mode = mode})
end

function R:markdown(text)
	return self.text(text, "Markdown")
end

function R:html(text)
	return self.text(text, "HTML")
end

function R:photo(file, caption, captionMode)
	return self.sendGeneric("sendPhoto", {photo = resolveFile(file), caption = caption, parse_mode = captionMode})
end

-- audio
-- document
-- sticker
function R:video(file, caption, captionMode, duration, width, height, streaming)
	return self.sendGeneric("sendVideo", {video = file, duration = duration, caption = caption, parse_mode = captionMode, width = width, height = height, supports_streaming = streaming})
end
-- videoNote
-- voice

function R:mediaGroup(media)
	return self.sendGeneric("sendMediaGroup", {media = media})
end

function R:location(latitude, longitude)
  return self.sendGeneric("sendLocation", {latitude = latitude, longitude = longitude})
end

-- venue

function R:contact(phone, firstname, lastname)
  return self.sendGeneric("sendContact", {phone_number = phone, first_name = firstname, last_name = lastname})
end

-- game

function R:dice()
	return self.sendGeneric("sendDice")
end


-----------------
-- *Modifiers* --
-----------------
function R:reply(msg)
	local msg_id = msg -- id
	if istable(msg) then msg_id = resolveMessage(msg) end -- msg #todo нужна ли проверка на table, есть в resolve есть?

	self.parameters.reply_to_message_id = msg_id
	return self
end

function R:selective(bForce)
	self.parameters.selective = fSelective ~= false
	return self
end

function R:forceReply(bForce)
	if not self.parameters["reply_markup"] then self.parameters["reply_markup"] = {} end
	local markup = self.parameters["reply_markup"]

	markup.force_reply = bForce ~= false
	return self
end

function R:keyboard(tKeys, bResize, bOneTime)
	if not self.parameters["reply_markup"] then self.parameters["reply_markup"] = {} end
	local markup = self.parameters["reply_markup"]

	if not tKeys then -- false/nil/null
		markup.keyboard = nil
		markup.resize_keyboard = nil
		markup.one_time_keyboard = nil

		if tKeys == false then
			markup.remove_keyboard = true
		else
			markup.remove_keyboard = nil
		end
	end

	markup.keyboard = tKeys or nil
	markup.one_time_keyboard = bOneTime ~= false
	markup.resize_keyboard   = bResize
	return self
end

function R:inlineKeyboard(tKeys)
	if not self.parameters["reply_markup"] then self.parameters["reply_markup"] = {} end
	local markup = self.parameters["reply_markup"]

	markup.inline_keyboard = tKeys
	return self
end

function R:disablePreview(bDisable)
	self.parameters["disable_web_page_preview"] = bDisable ~= false
	return self
end

function R:silent(bMute)
	self.parameters["disable_notification"] = bMute ~= false
	return self
end


---------------------
-- *other actions* --
---------------------
function R:action(action)
	return self.sendGeneric("sendChatAction", {action = action});
end

function R:editText(msg, text, mode)
	local parameters = {text = text, parse_mode = mode}
	if isstring(msg) then
		parameters["inline_message_id"] = msg
	else
		parameters["message_id"] = resolveMessage(msg)
	end
	return self.sendGeneric("editMessageText", parameters)
end

function R:editMarkdown(msg, text)
	return self.editText(msg, text, "Markdown")
end

function R:editHTML(msg, text)
	return self.editText(msg, text, "HTML")
end

-- editCaption
function R:editReplyMarkup(msg)
	local parameters = {}
	if isstring(msg) then
		parameters.inline_message_id = msg
	else
		parameters.message_id = resolveMessage(msg)
	end
	return self.sendGeneric("editMessageReplyMarkup", parameters)
end

function R:deleteMessage(msg)
	local parameters = { message_id = resolveMessage(msg) }
	return self.sendGeneric("deleteMessage", parameters);
end




local REPLY_MT = {} -- чтобы методы можно было вызывать через точку, а не двоеточие
REPLY_MT.__index = function(self, sMethod)
	local fMethod = R[sMethod]
	return function(...) return fMethod(self, ...) end -- fp
end


local exports = {}

exports.get_instance = function(bot, chat_id)
	return setmetatable({
		bot = bot,
		id  = chat_id,
		parameters = {}
	}, REPLY_MT)
end

return exports
