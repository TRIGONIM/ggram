-- This file is used if you run ggram outside of Garry's Mod.
-- It contains some features that are in Garry's Mod and that the framework uses

do -- PrintTable
	local function MsgC(...)
		local args = {...}
		local str = ""
		for i = 1,#args do
			str = str .. tostring(args[i])
		end
		io.write(str)
	end

	local function MsgN(s) MsgC(s .. "\n") end
	local function GetTextSize(x) return x:len(), 1 end

	local function FixTabs(x, width)
		local curw = GetTextSize(x)
		local ret = ""
		while (curw < width) do -- not using string.rep since linux
			x    = x .. " "
			ret  = ret .. " "
			curw = GetTextSize(x)
		end
		return ret
	end

	local replacements = {
		["\n"] = "\\n", ["\r"] = "\\r",
		["\v"] = "\\v", ["\f"] = "\\f",
		["\x00"] = "\\x00", ["\\"] = "\\\\", ["\""] = "\\\"",
	}

	local typesmap = {
		boolean = true, ["function"] = true,
		number = true, string = true,
		table = true, func = true,
	}

	local function DebugFixToString(obj)
		local typ = type(obj)
		if typ == "string" then
			return "\"" .. obj:gsub(".", replacements) .. "\""
		end

		if typesmap[typ] then
			return tostring(obj)
		end

		return "(" .. typ .. ") " .. tostring(obj)
	end

	function PrintTable(tbl, spaces, done)
		spaces = spaces or 0
		done = done or {}

		local buffer = {}
		local rbuf = {}
		local maxwidth = 0

		done[tbl] = true
		for key,val in pairs(tbl) do
			rbuf[#rbuf + 1]  = key
			buffer[#buffer + 1] = "[" .. DebugFixToString(key) .. "] "
			maxwidth = math.max(GetTextSize(buffer[#buffer]), maxwidth)
		end
		local str = string.rep(" ", spaces)
		if (spaces == 0) then MsgN("\n") end
		MsgC("{\n")
		local tabbed = str .. string.rep(" ", 4)

		for i = 1, #buffer do
			local key = rbuf[i]
			local value = tbl[key]
			MsgC(tabbed .. "[")
			MsgC( DebugFixToString(key) )
			MsgC("] " .. FixTabs(buffer[i], maxwidth), "= ")
			if (type(value) == "table" and not done[value]) then
				PrintTable(tbl[key], spaces + 4, done)
			else
				MsgC( DebugFixToString(value) )
			end
			MsgC(",")
			MsgN("")
		end
		MsgC(str .. "}")
		if (spaces == 0) then
			MsgN("")
		end
	end

	-- PrintTable(_G)


	function prt(t)
		PrintTable(t)
	end

	function PRINT(...)
		local count = select("#", ...)
		local args = {...}

		if count > 1 then
			PrintTable(args)
		else
			_G[istable(args[1]) and "prt" or "print"](...)
		end
	end
end

do -- timer (for deferred.sleep)
	local copas = require("copas")

	timer = {}
	function timer.Simple(delay, func)
		copas.addthread(function()
			copas.sleep(delay)
			func()
		end)
	end
end

do -- cookie (for polling offsets and session middleware)
	local tmppath = "ggram"
	os.execute("mkdir -p " .. tmppath)

	cookie = {}
	function cookie.GetString(name, default)
		local f = io.open(tmppath .. "/" .. name .. ".txt", "r")
		if not f then return default end

		local result = f:read("*all")
		f:close()
		return result
	end

	function cookie.GetNumber(name, default)
		return tonumber( cookie.GetString(name) ) or default
	end

	function cookie.Set(name, value)
		local f = assert(io.open(tmppath .. "/" .. name .. ".txt", "w"))
		f:write(value)
		f:close()
	end

	-- print("coo", cookie.GetString("asd", "Ку"))
	-- if 1 then return end
end

do -- json
	util = {}
	-- local json = require("ggram.glua.json")
	local json = require("dkjson")
	util.JSONToTable = json.decode
	util.TableToJSON = function(t, bPretty) return json.encode(t, bPretty and {indent = true}) end
end

do -- is* functions
	function isnumber(v) return type(v) == "number"  end
	function isbool(v)   return type(v) == "boolean" end
	function istable(v)  return type(v) == "table"   end
	function isstring(v) return type(v) == "string"  end
end


do -- table extension
	function table.Copy( t, lookup_table )
		if ( t == nil ) then return nil end

		local copy = {}
		setmetatable( copy, debug.getmetatable( t ) )
		for i, v in pairs( t ) do
			if ( not istable( v ) ) then
				copy[ i ] = v
			else
				lookup_table = lookup_table or {}
				lookup_table[ t ] = copy
				if ( lookup_table[ v ] ) then
					copy[ i ] = lookup_table[ v ] -- we already copied this table. reuse the copy.
				else
					copy[ i ] = table.Copy( v, lookup_table ) -- not yet copied. copy it.
				end
			end
		end
		return copy
	end
end

do -- string.Split for extend_message.lua
	function string.ToTable( str )
		local tbl = {}

		for i = 1, string.len( str ) do
			tbl[i] = string.sub( str, i, i )
		end

		return tbl
	end

	local totable = string.ToTable
	local string_sub = string.sub
	local string_find = string.find
	local string_len = string.len
	function string.Explode(separator, str, withpattern)
		if ( separator == "" ) then return totable( str ) end
		if ( withpattern == nil ) then withpattern = false end

		local ret = {}
		local current_pos = 1

		for i = 1, string_len( str ) do
			local start_pos, end_pos = string_find( str, separator, current_pos, not withpattern )
			if ( not start_pos ) then break end
			ret[ i ] = string_sub( str, current_pos, start_pos - 1 )
			current_pos = end_pos + 1
		end

		ret[ #ret + 1 ] = string_sub( str, current_pos )

		return ret
	end

	function string.Split( str, delimiter )
		return string.Explode( delimiter, str )
	end
end

do -- http
	http = require("ggram.glua.http_async")
	HTTP = http.request
end
