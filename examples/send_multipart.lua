-- Run this file with lua multipart.lua

--[[Для отправки файлов используется content-type `multipart/form-data`,
	а сами данные передаются в особом формате в теле POST запроса.
	В Lua и gLua нет встроенной поддержки отправки таких запросов,
	поэтому используется сторонняя библиотека lua-multipart:
	https://github.com/Kong/lua-multipart/tree/master ]]

--[[Заметка для пользователей с Garry's Mod:
	Гмод разрешает записывать в файловую систему (file.Write) файлы
	только с расширениями .txt, .dat и еще некоторыми другими (https://wiki.facepunch.com/gmod/file.Write),
	но при этом мы все равно можем скачать через http.Fetch условно .gif,
	записать его как .txt, затем отправить этот .txt в телеграм как .gif и он успешно отобразится ]]

local ggram = require("ggram")
local http_fetch = require("http_async").get -- https://github.com/TRIGONIM/lua-requests-async


local bot = ggram("123456789:QWERTYUIOPASDFGHJKLZXCVBNM") -- replace with your token (t.me/BotFather)
require("ggram.polling").start(bot) -- start getUpdates loop


local function request()
	return bot.reply(123456) -- paste here your chat_id. Find it in @jsonson_bot
end

local photo_url = "https://file.def.pm/n9784Dep.jpg"

-- You can send photo without using multipart. Just by photo url
request().photo(photo_url)
request().photo(photo_url, "*caption*", "markdown") -- caption and parse_mode optionally can be set
request().setParameter("caption", "caption").photo(photo_url) -- alternative method to set parameters

-- Now you can see example, where we download the image and send it with multipart/form-data as file
http_fetch(photo_url, function(raw_photo)
	request().photo({raw_data})
end)

-- Next example shows how to send files within handlers
bot.command("document", function(ctx)
	http_fetch(photo_url, function(raw_photo)
		ctx.reply.document({raw_photo, "image.jpg"})
		ctx.reply.protect().document({raw_photo, "image.jpg"}, "this is caption. Content is protected from saving and forwarding") -- use modifiers
		ctx.reply.setParameter("protect_content", true).document({raw_photo, "name.jpg"}, "the same variant as a bit above")
	end)
end)

-- Here we set optional additional file for request called "thumbnail"
bot.command("video_with_thumbnail", function(ctx)
	http_fetch("https://file.def.pm/file_50mb.mp4", function(video_raw)
		http_fetch("https://file.def.pm/bfUL7owI.jpg", function(thumb_raw)
			ctx.reply
				.setFile("thumbnail", thumb_raw, "thumb.jpg")
				.video({video_raw, "file.mp4"}, "*bold* caption", "markdown", 29, 1920, 1080)
		end)
	end)
end)

-- launch http requests, timers etc
ggram.idle()
