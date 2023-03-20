--[[-------------------------------------------------------------------------
	reply. methods
---------------------------------------------------------------------------]]

local multipart = ggram.include("surprise/multipart")
local RESP = ggram.methods

local format_parameters = ggram.include("core/request").format_parameters
function RESP:sendMultipart(method, form_data)
	self.parameters.chat_id = self.id

	local params = format_parameters(self.parameters)
	for name,value in pairs(params) do
		form_data:AddField(name, value)
	end

	return self.bot.call_method(method, {}, {
		body = form_data:BuildBody(),
		type = "multipart/form-data;charset=utf-8;boundary=" .. form_data.boundary
	})
end

function RESP:animationFromFile(file_content, name)
	local form_data = multipart.FormData():AddFile("animation", file_content, name)
	return self.sendMultipart("sendAnimation", form_data)
end

function RESP:photoFromFile(file_content, name)
	local form_data = multipart.FormData():AddFile("photo", file_content, name)
	return self.sendMultipart("sendPhoto", form_data)
end

function RESP:mediaGroupFromFiles(files) -- {{type = "photo", media = RAW_DATA, caption...}, ...}
	local form_data = multipart.FormData()

	local tbl = {}
	for i,f in ipairs(files) do
		form_data:AddFile("unique" .. i, f.media, "anydata?")
		tbl[i] = {
			type  = f.type,
			media = "attach://unique" .. i,
		}
		for k,v in pairs(f) do -- merge additional File properties if not exists
			tbl[i][k] = tbl[i][k] or v
		end
	end

	form_data:AddTable("media", tbl)
	return self.sendMultipart("sendMediaGroup", form_data)
end
