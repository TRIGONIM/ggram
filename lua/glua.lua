-- This file is used if you run ggram outside of Garry's Mod.
-- It contains some features that are in Garry's Mod and that the framework uses

do -- timer (for deferred.sleep)
	timer = {}

	local ti = require("gmod.timer")
	timer.Create = ti.Create
	timer.Simple = ti.Simple
	timer.Remove = ti.Remove
end

do -- cookie (for polling offsets and session middleware)
	cookie = {}

	local co = require("gmod.cookie")
	cookie.GetString = co.GetString
	cookie.GetNumber = co.GetNumber
	cookie.Set       = co.Set
	cookie.Delete    = co.Delete
end

do -- json
	util = {}

	local ut = require("gmod.util")
	util.JSONToTable = ut.JSONToTable
	util.TableToJSON = ut.TableToJSON
end

do -- is* functions
	local gl = require("gmod.globals")

	isnumber = gl.isnumber
	isbool   = gl.isbool
	istable  = gl.istable
	isstring = gl.isstring
end

do -- table extension
	local ta = require("gmod.table")

	table.Copy = ta.Copy
end

do -- string.Split for extend_message.lua
	local st = require("gmod.string")

	string.Split = st.Split
end
