<img align="left" width="80" src="https://i.imgur.com/AbYOj2T.png">

# ggram – Telegram Bot Framework

> NEED TRANSLATORS. Please, make pull requests if you wanna help. Temporarily I recommend https://www.deepl.com/translator to translate [this page](/readme.md)

<p align="left">
	<img src="https://img.shields.io/github/languages/code-size/TRIGONIM/ggram">
	<img src="https://img.shields.io/github/license/TRIGONIM/ggram">
</p>

Создавайте Telegram ботов любой сложности и **запускайте их на Garry's Mod сервере**

<img align="right" width="300" src="https://user-images.githubusercontent.com/9200174/135781831-dbb545a9-b3d9-4d0a-ba58-dd42935d35f0.png">

```lua
local bot = ggram("token")

bot.enable_polling() -- enables getUpdates loop

bot.command("start", function(ctx)
	ctx.reply.text("Hello @" .. ctx.from.username)
end)
```

Дополнительные примеры можно найти в папке [/bots](/lua/ggram/bots)

## 🔥 Начало использования
0. У вас уже должен быть создан бот через [@BotFather](https://t.me/BotFather)
1. Скачайте ggram с этого репозитория и установите в `/addons/ggram`
2. Создайте файл `/addons/ggram_bots/lua/ggram/bots/anyname/_init.lua`
3. Заполните его содержимым демонстративного бота из папки [/bots/example](/lua/ggram/bots/example), заменив токен

## 💡 Сделано на GGRAM + скриншоты
[Здесь (клик)](https://forum.gm-donate.ru/t/idei-telegram-botov-dlya-vashego-servera/197) опубликованы ссылки на работающие боты, а также множество идей, которые можно реализовать при помощи этого фреймворка для своего Garry's Mod сервера и не только. Возможности практически безграничны.

## ✨ Особенности
- Работает прямо с Garry's Mod сервера
- НЕ требует никаких сторонних .dll или WEB прослоек
- Очень минималистичный и легко расширяемый
- [Возможность](/lua/ggram/includes/surprise) отправки анимаций, документов, изображений
- Создан с учетом многолетного опыта создания ботов
- Дружит с парадигмой функционального программирования

## 📚 Документация
- 🤔 [Что такое и как использовать update, context, middleware, reply](/info/understanding_things.md) (основные сущности)
- 🗂 [Где создавать бота, что кидать в extensions и зачем нужна includes](/info/project_structure.md)


---
> _Если остались вопросы, вы можете задать их в Telegram @amd_nick или создать Issue_
