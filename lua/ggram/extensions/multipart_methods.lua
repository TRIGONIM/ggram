-- reply.methods

local json_encode = (util or require("gmod.util")).TableToJSON
local Multipart = require("multipart")

local RESP = require("ggram.reply")

local format_parameters = require("ggram.request").format_parameters
-- Аналог sendGeneric, но для multipart
-- @todo v3 удалить этот метод, интегрировать в sendGeneric
-- @function sendMultipart
-- @tparam string method Telegram API метод
-- @tparam table form_data сгенерировано через multipart.lua
-- @treturn Promise deferred object
function RESP:sendMultipart(method, form_data)
	self.parameters.chat_id = self.id

	local params = format_parameters(self.parameters)
	for name,value in pairs(params) do
		form_data:set_simple(name, value)
	end

	return self.bot.call_method(method, nil, {
		body = form_data:tostring(),
		type = "multipart/form-data;charset=utf-8;boundary=" .. Multipart.RANDOM_BOUNDARY
	})
end

function RESP:documentFromFile(file_content, name)
	local form_data = Multipart()
	form_data:set_simple("document", file_content, name)
	return self.sendMultipart("sendDocument", form_data)
end

function RESP:photoFromFile(file_content, name)
	local form_data = Multipart()
	form_data:set_simple("photo", file_content, name)
	return self.sendMultipart("sendPhoto", form_data)
end

function RESP:mediaGroupFromFiles(files) -- {{type = "photo", media = RAW_DATA, caption...}, ...}
	local form_data = Multipart()

	local tbl = {}
	for i,f in ipairs(files) do
		form_data:set_simple("unique" .. i, f.media, "anydata?")
		tbl[i] = {
			type  = f.type,
			media = "attach://unique" .. i,
		}
		for k,v in pairs(f) do -- merge additional File properties if not exists
			tbl[i][k] = tbl[i][k] or v
		end
	end

	form_data:set_simple("media", json_encode(tbl))
	return self.sendMultipart("sendMediaGroup", form_data)
end

-- local fileContent = io.open("testfile.png", "rb"):read("*a")
-- local bot = TLG_STEAM
-- -- bot.reply(TLG_AMD).photoFromFile(fileContent, "testfile.png")
-- -- bot.reply(TLG_AMD).documentFromFile(fileContent, "testfile.png")
-- bot.reply(TLG_AMD).mediaGroupFromFiles({
-- 	{type = "photo", media = fileContent, caption = "Hello world"},
-- 	{type = "photo", media = fileContent},
-- })
