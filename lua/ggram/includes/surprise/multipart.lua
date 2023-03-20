local multipart = {}

--[[-------------------------------------------------------------------------
	SectionInfo
---------------------------------------------------------------------------]]
local function SectionInfo(data, fields, content_encoding, content_type)
	local OBJ = {
		data             = data or "",
		fields           = fields or {},
		content_type     = content_type,
		content_encoding = content_encoding,
	}

	function OBJ:BuildBody()
		local body = {}
		local content_disposition = nil
		do
			local cd = {"Content-Disposition: form-data"}
			for name, value in pairs(self.fields) do
				table.insert(cd, string.format("%s=%q", name, value))
			end
			content_disposition = table.concat(cd, ";")
		end
		table.insert(body, content_disposition)
		if self.content_type then
			table.insert(body, "Content-Type: " .. self.content_type)
		end
		if self.content_encoding then
			table.insert(body, "Content-Transfer-Encoding: " .. self.content_encoding)
		end
		table.insert(body, "")
		table.insert(body, self.data)
		return table.concat(body, "\r\n")
	end

	return OBJ
end

--[[-------------------------------------------------------------------------
	FormData
---------------------------------------------------------------------------]]
local function string_random(chars)
	local str = ""
	for i = 1, chars do
		str = str .. string.char(math.random(97, 122)) -- a-z
	end
	return str
end

function multipart.FormData()
	local OBJ = {
		boundary = string_random(64),
		sections = {}
	}

	function OBJ:AddField(key, value)
		local field = SectionInfo(value, {name = key}, "8bit")
		table.insert(self.sections, field)
		return self
	end

	function OBJ:AddTable(key, tData)
		local json = SectionInfo(util.TableToJSON(tData), {name = key},
			"8bit", "application/json;charset=utf8")

		table.insert(self.sections, json)
		return self
	end

	function OBJ:AddFile(key, data, file_name)
		local file = SectionInfo(data, {name = key, filename = file_name},
			"binary", "application/octet-stream")

		table.insert(self.sections, file)
		return self
	end

	function OBJ:BuildBody()
		local body = {}
		for _, section in ipairs(self.sections) do
			table.insert(body, section:BuildBody())
		end
		body = table.concat(body, "\r\n--" .. self.boundary .. "\r\n")
		return "--" .. self.boundary .. "\r\n" .. body .. "\r\n--" .. self.boundary .. "--" .. "\r\n"
	end

	return OBJ
end

return multipart
