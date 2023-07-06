-- import example:
-- local coro = require("ggram").include("helpers.coro").coroutinize

-- Yield с функцией "продолжить" внутри f:
-- coroutine.yield(function(cont) some_async(function(res) cont(res) end) end)
local coroutinize = function(f, ...)
	local co = coroutine.create(f)
	local function exec(...)
		local ok, data = coroutine.resume(co, ...)
		if not ok then
			error( debug.traceback(co, data) )
		end
		if coroutine.status(co) ~= "dead" then
			data(exec)
		end
	end
	exec(...)
end

local deferred_to_yield = function(deferred_func)
	-- оверрайдим функцию метода, вызывая оригинальный, но превращая в корутину
	return function(...)
		local args = {...}
		return coroutine.yield(function(cb)
			deferred_func( unpack(args) ):next(function(res)
				cb(true, res)
			end, function(err)
				cb(false, err)
			end)
		end)
	end
end

local timer_Simple = timer and timer.Simple or require("gmod.timer").Simple
local wait = function(seconds)
	coroutine.yield(function(cont)
		timer_Simple(seconds, cont)
	end)
end

return {
	coroutinize = coroutinize,
	deferred_to_yield = deferred_to_yield,
	wait = wait,
}
