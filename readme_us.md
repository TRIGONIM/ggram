<img align="left" width="80" src="https://i.imgur.com/AbYOj2T.png">

# ggram – Telegram Bot Framework

> 🇬🇧 🇺🇸 NEED TRANSLATORS. Please, make pull requests if you wanna help. Temporarily I recommend deepl to translate this page
> 

<p align="left">
	<img src="https://img.shields.io/github/languages/code-size/TRIGONIM/ggram">
	<img src="https://img.shields.io/github/license/TRIGONIM/ggram">
</p>

Create Telegram bots of any difficulty and start them on your own **Garry’s Mod server**

![https://user-images.githubusercontent.com/9200174/135781831-dbb545a9-b3d9-4d0a-ba58-dd42935d35f0.png](https://user-images.githubusercontent.com/9200174/135781831-dbb545a9-b3d9-4d0a-ba58-dd42935d35f0.png)

```
local bot = ggram("token")bot.enable_polling() -- enables getUpdates loopbot.command("start", function(ctx)    ctx.reply.text("Hello @" .. ctx.from.username)end)
```

Extra examples can be found in the [/bots](/lua/ggram/bots) directory

## 🔥 Start of using

1. You should have already created a bot using [@BotFather](https://t.me/BotFather).
2. Download ggram from this repository and install it in `/addons/ggram'.
3. Create the file `/addons/ggram_bots/lua/ggram/bots/anyname/_init.lua`.
4. Copy the code of the example bot from [/bots/example](notion://www.notion.so/lua/ggram/bots/example) into the file you just created. Do not forget to replace the token.

## 💡 Made with GGRAM + screenshots

Ready-made bots, ideas that you could implement using this framework for your Garry's Mod server, and many more interesting things are posted [here (click)]((https://forum.gm-donate.ru/t/idei-telegram-botov-dlya-vashego-servera/197)). The possibilities are almost endless.

## ✨ Features

- Works directly on your Garry’s Mod servers
- DOESN'T require any 3rd-party .dll or WEB proxies
- Very minimalistic and easily expandable
- [The possibility](/lua/ggram/includes/surprise) send animations, documents and images
- Developed based on years of experience in creating bots
- Functional programming friendly

## 📚 Documentation

- 🤔 What [update, context, middleware, reply](/info/understanding_things.md) are and how to use them (the fundamentals).
- 🗂 [Where to create a bot, what to put in the extensions folder, and why the includes folder exists](/info/project_structure.md)

---

> If you still have questions, you can ask them in Telegram @amd_nick or create an Issue
>
