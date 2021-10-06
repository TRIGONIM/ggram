# readme

![https://i.imgur.com/AbYOj2T.png](https://i.imgur.com/AbYOj2T.png)

# ggram – Telegram Bot Framework

> 🇬🇧 🇺🇸 NEED TRANSLATORS. Please, make pull requests if you wanna help. Temporarily I recommend deepl to translate this page
> 

[https://img.shields.io/github/languages/code-size/TRIGONIM/ggram](https://img.shields.io/github/languages/code-size/TRIGONIM/ggram)

[https://img.shields.io/github/license/TRIGONIM/ggram](https://img.shields.io/github/license/TRIGONIM/ggram)

Create Telegram bots any difficulty and start it on your own **Garry’s Mod server**

![https://user-images.githubusercontent.com/9200174/135781831-dbb545a9-b3d9-4d0a-ba58-dd42935d35f0.png](https://user-images.githubusercontent.com/9200174/135781831-dbb545a9-b3d9-4d0a-ba58-dd42935d35f0.png)

```
local bot = ggram("token")bot.enable_polling() -- enables getUpdates loopbot.command("start", function(ctx)    ctx.reply.text("Hello @" .. ctx.from.username)end)
```

Extra examples can be found in directory [/bots](/lua/ggram/bots)

## 🔥 Start of using

1. You should have already created a bot using [@BotFather](https://t.me/BotFather).
2. Download ggram from this repository and install it in `/addons/ggram'.
3. Create a file `/addons/ggram_bots/lua/ggram/bots/anyname/_init.lua`.
4. Fill it with bot example from [/bots/example](notion://www.notion.so/lua/ggram/bots/example), replacing token

## 💡 Made on GGRAM + screenshots

Here [(*click*)](https://forum.gm-donate.ru/t/idei-telegram-botov-dlya-vashego-servera/197) (not for English) was uploaded links on working bots, also many ideas, which you can implement with this framework for your Garry's Mod server and not only. The possibilities are almost endless.

## ✨ Features

- Works directly with Garry’s Mod servers
- DOESN'T require any 3rd-party .dll or WEB interfaces
- Very minimalistic and easily expandable
- [Opportunity](/lua/ggram/includes/surprise) send animations, documents and images
- Created with years of experience in creating bots
- Friendly with the functional programming paradigm

## 📚 Documentation

- 🤔 What is and how to use [update, context, middleware, reply](/info/understanding_things.md) (basic entities)
- 🗂 [Where to create bot, what to put in extensions and for what need includes](/info/project_structure.md)

---

> If you still have questions, you can ask them in Telegram @amd_nick or create an Issue
>
