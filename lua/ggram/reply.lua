--- Обертка для вызова API методов Telegram
-- @classmod Reply
-- @usage
-- -- Использование из любого места в коде:
-- bot.reply(123456).text("Hello") -- где bot это объект бота, а 123456 это chat_id
-- -- Доступ внутри хендлеров происходит через context объект
-- bot.command("test", function(ctx) ctx.reply.text("Hello") end) -- chat_id уже забинджен
-- -- Еще несколько примеров:
-- ctx.reply.text("*Жирный текст*", "Markdown")
-- ctx.reply.markdown("*Аналогичная запись*")
-- ctx.reply.silent().text("Будет отправлено без звука")
-- ctx.reply.setParameter("disable_notification", true).text("Аналогичный вариант без звука")

local table_Copy = table.Copy or require("gmod.table").Copy

local REPLY_MT = {} --- чтобы методы можно было вызывать через точку, а не двоеточие
REPLY_MT.__index = function(self, sMethod)
	local fMethod = REPLY_MT[sMethod]
	if not fMethod then
		print("TRACE: " .. debug.traceback())
		error("reply." .. sMethod .. " is not a valid method")
	end
	return function(...) return fMethod(self, ...) end -- fp
end


local function resolveMessage(msg)
	assert(msg, "ggram: msg expected, got nil")
	return tonumber(msg) or msg.message_id
end

-- local function resolveChat(chat)
-- 	return tonumber(chat) or chat.id
-- end

local function resolveFile(file)
	local expr = (type(file) == "table" and file.id) or (type(file) == "string" and file)
	return assert(expr, "Invalid file or file ID")
end

--- Отправить запрос на Telegram API
-- @string method API метод
-- @tparam[opt] table additionalParameters набор параметров, которые не были указаны через reply.setParameter
function REPLY_MT:sendGeneric(method, additionalParameters)
	local parameters = table_Copy(self.parameters)
	self.parameters = {}

	parameters.chat_id = self.id
	for k,v in pairs(additionalParameters or {}) do -- merge
		parameters[k] = v
	end

	return self.bot.call_method(method, parameters)
end

-- *methods functions*
-- Не доделана https://github.com/botgram/botgram/blob/master/lib/reply.js#L128-L135
-- function REPLY_MT:forward(msg_id, chat_id)
-- 	return self.sendGeneric("forwardMessage", {message_id = resolveMessage(msg_id), from_chat_id = resolveChat(chat_id)})
-- end

--- Отправка sendMessage
function REPLY_MT:text(text, mode)
	return self.sendGeneric("sendMessage", {text = text, parse_mode = mode})
end

--- Alias для ctx.reply.text(text, "Markdown")
function REPLY_MT:markdown(text)
	return self.text(text, "Markdown")
end

--- Alias для ctx.reply.text(text, "HTML")
function REPLY_MT:html(text)
	return self.text(text, "HTML")
end

--- Отправка sendPhoto
function REPLY_MT:photo(file, caption, captionMode)
	return self.sendGeneric("sendPhoto", {photo = resolveFile(file), caption = caption, parse_mode = captionMode})
end

-- audio
-- document
-- sticker
--- Отправка sendVideo
function REPLY_MT:video(file, caption, captionMode, duration, width, height, streaming)
	return self.sendGeneric("sendVideo", {video = file, duration = duration, caption = caption, parse_mode = captionMode, width = width, height = height, supports_streaming = streaming})
end

--- Отправка sendAnimation
function REPLY_MT:animation(file, caption, captionMode)
	return self.sendGeneric("sendAnimation", {animation = resolveFile(file), caption = caption, parse_mode = captionMode})
end
-- videoNote
-- voice

--- Отправка sendMediaGroup
function REPLY_MT:mediaGroup(media)
	return self.sendGeneric("sendMediaGroup", {media = media})
end

--- Отправка sendLocation
function REPLY_MT:location(latitude, longitude)
	return self.sendGeneric("sendLocation", {latitude = latitude, longitude = longitude})
end

-- venue

--- Отправка sendContact
function REPLY_MT:contact(phone, firstname, lastname)
	return self.sendGeneric("sendContact", {phone_number = phone, first_name = firstname, last_name = lastname})
end

-- game

--- Отправка sendDice
function REPLY_MT:dice()
	return self.sendGeneric("sendDice")
end

-- other actions --

--- Отправка sendChatAction
function REPLY_MT:action(action)
	return self.sendGeneric("sendChatAction", {action = action})
end

--- Отправка editMessageText
function REPLY_MT:editText(msg, text, parse_mode)
	local parameters = {text = text, parse_mode = parse_mode}
	if type(msg) == "string" then
		parameters["inline_message_id"] = msg
	else
		parameters["message_id"] = resolveMessage(msg)
	end
	return self.sendGeneric("editMessageText", parameters)
end

--- Alias для editText, force Markdown parse_mode
function REPLY_MT:editMarkdown(msg, text)
	return self.editText(msg, text, "Markdown")
end

--- Alias для editText, force HTML parse_mode
function REPLY_MT:editHTML(msg, text)
	return self.editText(msg, text, "HTML")
end

-- editCaption

--- Отправка editMessageReplyMarkup
function REPLY_MT:editReplyMarkup(msg)
	local parameters = {}
	if type(msg) == "string" then
		parameters.inline_message_id = msg
	else
		parameters.message_id = resolveMessage(msg)
	end
	return self.sendGeneric("editMessageReplyMarkup", parameters)
end

--- Отправка deleteMessage
function REPLY_MT:deleteMessage(msg)
	local parameters = { message_id = resolveMessage(msg) }
	return self.sendGeneric("deleteMessage", parameters)
end

-- modifiers --

--- Модификатор, устанавливает параметр запроса
-- @usage ctx.reply.setParameter("disable_notification", true).text("Hello")
function REPLY_MT:setParameter(key, value)
	self.parameters[key] = value
	return self
end

--- Модификатор, добавляет параметр reply_to_message_id
-- @usage ctx.reply.reply(ctx).text("Reply to message")
function REPLY_MT:reply(msg)
	local msg_id = msg -- id
	if type(msg) == "table" then msg_id = resolveMessage(msg) end -- msg #todo нужна ли проверка на table, есть в resolve есть?

	self.parameters.reply_to_message_id = msg_id
	return self
end

--- Модификатор, добавляет параметр selective
-- @usage ctx.reply.keyboard({{"button"}}, true).selective().markdown("*Hello*")
function REPLY_MT:selective(bForce)
	self.parameters.selective = fSelective ~= false
	return self
end

--- Модификатор, добавляет параметр force_reply
function REPLY_MT:forceReply(bForce)
	if not self.parameters["reply_markup"] then self.parameters["reply_markup"] = {} end
	local markup = self.parameters["reply_markup"]

	markup.force_reply = bForce ~= false
	return self
end

--- Модификатор, добавляет параметр keyboard, resize_keyboard, one_time_keyboard
-- @usage ctx.reply.keyboard({{"button"}}, true).text("Hello")
function REPLY_MT:keyboard(tKeys, bResize, bOneTime)
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

--- Модификатор, добавляет параметр inline_keyboard
-- @usage ctx.reply.inlineKeyboard({{ {text = "text", callback_data = "any"} }}).text("kb")
function REPLY_MT:inlineKeyboard(tKeys)
	if not self.parameters["reply_markup"] then self.parameters["reply_markup"] = {} end
	local markup = self.parameters["reply_markup"]

	markup.inline_keyboard = tKeys
	return self
end

--- Модификатор, добавляет параметр disable_web_page_preview (чтобы ссылки в сообщении не создавали превью)
-- @usage ctx.reply.disablePreview().markdown("https://youtube.com")
function REPLY_MT:disablePreview(bDisable)
	self.parameters["disable_web_page_preview"] = bDisable ~= false
	return self
end

--- Модификатор, добавляет параметр disable_notification (отправка сообщений без звука)
function REPLY_MT:silent(bMute)
	self.parameters["disable_notification"] = bMute ~= false

	return self
end

return REPLY_MT
