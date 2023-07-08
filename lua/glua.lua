-- This file is used if you run ggram outside of Garry's Mod.
-- It contains some features that are in Garry's Mod and that the framework uses

do -- timer (for deferred.sleep)
	timer = timer or {}

	local ti = require("gmod.timer")
	timer.Create = ti.Create
	timer.Simple = ti.Simple
	timer.Remove = ti.Remove
end

do -- table extension
	local ta = require("gmod.table")

	table.Copy = ta.Copy
end
