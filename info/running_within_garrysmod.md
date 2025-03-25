# Запуск на Garry's Mod сервере

> ⚠️ В Garry's Mod немного другие принципы структуризации файлов, нежели в чистом Lua. В гмоде не принято сверху каждого файла делать какие-либо `require()`, но принято все помещать в глобальное пространство. Несмотря на то, что ggram делается с уклоном на традиционность Lua, ниже приводится пример, который делает ggram глобальным, а подгрузку ботов и расширений не опциональной, а автоматической, как принято в Garry's Mod.

Снизу будет пример загрузчика, благодаря которому я запускал код всех ботов сразу.

## ↪️ Порядок загрузки

1. /addons/ggram-mod/lua/autorun/ggram-launcher.lua _(код ниже)_
2. /addons/ggram/lua/ggram.lua _(загрузится сама библиотека, поместится в глобальное пространство, чтобы не обязательно было всегда делать `local ggram = require("ggram")`)_
3. /addons/ggram-mod/lua/`ggram/extensions/*.lua` _(сюда вы можете поместить любые штучки-дрючки, которые можете захотеть использовать в ботах, например глобальные chat_id, дополнительные методы, хелпер-функции)_
4. /addons/ggram-mod/lua/`ggram/bots/*/_init.lua` _(папки с вашими ботами. \_init.lua файл в папке будет главным файлом ващего бота. Внутри него другие файлы можно подключить через `include("path")`)_

## ℹ️ Описание структуры

<img align="left" width="450" src="https://file.def.pm/iAllq439.jpg">

### /extensions
Директория, хранящая в себе файлы, которые должны расширить самый базовый функционал всех ботов. Это могут быть модификаторы метатаблиц ботов, какие-то ENUM константы, функции-утилиты, например `escapeMarkdown(text)` и т.д. Эти файлы грузятся до загрузки самих ботов

### /bots
Директория, в которой вы должны хранить код ботов. Для каждого отдельного бота нужно создать свою поддиректорию. В `/bots/{anyname}` обязательно должен быть файл \_init.lua — этот файл будет загружен при include вашего бота. Вы можете создавать дополнительные файлы в `/bots/{botname}` и инклюдить их самостоятельно из-под \_init.lua.

---


## 🤖 Код загрузчика

Разместить по пути `addons/ggram-mod/lua/autorun/ggram-launcher.lua`

```lua
-- This file should be shared for loading prior to SERVER
-- If it is loaded too late, ggram-dependent scripts may throw errors
if CLIENT then return end

local function loadBots(path, iDeep)
	iDeep = iDeep or 0

	local files,dirs = file.Find(path .. "/*","LUA")
	for _,f in ipairs(files) do
		if f == "_init.lua" then
			print("GG Loading Bot " .. path)
			include(path .. "/" .. f)
			break
		end
	end

	for _,d in ipairs(iDeep > 0 and dirs or {}) do
		loadBots(path .. "/" .. d, iDeep - 1)
	end
end

local function loadExtensions(path)
	local files = file.Find(path .. "/*","LUA")
	for _,f in ipairs(files) do
		local fpath = path .. "/" .. f
		print("GG Loading " .. fpath)
		include(fpath)
	end
end

local gmod_require_override do
	local require_cache = {}
	gmod_require_override = function(path)
		if require_cache[path] ~= nil then
			return require_cache[path]
		end

		local content = include(path .. ".lua")
		require_cache[path] = content or false
		return content
	end
end

gg_require_orig = gg_require_orig or require
-- Override to make "require("deferred")", "require("ggram.middlewares.name")", etc. work.
function require(raw_path)
	local path = raw_path:gsub("%.", "/")
	if file.Exists(path .. ".lua", "LUA") then
		return gmod_require_override(path)
	end
	return gg_require_orig(raw_path)
end

ggram = require("ggram")
loadExtensions("ggram/extensions")
loadBots("ggram/bots", 1)
```

---

> _Если остались вопросы, вы можете задать их в Telegram @amd_nick или создать Issue_
