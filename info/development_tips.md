# 😮 Development tips and tricks

> Not relevant for Garry's Mod.

## launcher.lua

If you plan to create several bots, then instead of using separate files for each bot, you can use one file, which will run all the other bots about this scheme:

```lua
-- Optionally, the path to the folder with the modules
package.path = string.format("%s;%s;%s",
	"./path/?.lua",
	"./path/?/init.lua",
package.path)

-- List of bot code files
local bots = {"bot_file1", "bot_file2"}
for _,bot_name in ipairs(bots) do
	assert(pcall(require, bot_name))
	print(bot_name .. " loaded")
end

require("ggram").idle()
```

## Only one polling server

> Для тех, кто хочет работать с кучей ботов без личного веб сервера

Я [сделал микросервис](https://blog.amd-nick.me/poll-gmod-app-docs/), который принимает вебхуки от разных сервисов, а сам выступает в качестве polling сервера, подобно как работает getUpdates в Telegram. Все боты отправляют ему обновления, затем я HTTP GET запросом получаю их в одном месте.

Для работы с этим сервисом я написал небольшой фреймворк и если для вас это интересно, то я могу опубликовать гайд, как его применить.
