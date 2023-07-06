# 👩‍🔧 Troubleshooting

## Lua versioning problems

If multiple versions of Lua are installed on the host, which is **particularly relevant for Mac**, there is a **potential** problem because luarocks is not using the same version of Lua as the system defaults to.

**ggram tested with lua 5.3.6, lua 5.1 and luajit 2.0.5**

Therefore, in cases of version problems, it is sufficient to execute all luarocks commands with the parameter `--lua-dir=$(brew --prefix)/opt/lua@5.3`, for example `luarocks --lua-dir=$(brew --prefix)/opt/lua@5.3 install ggram`

The example is for Mac. On Linux lua will be in a different folder or the installed version of luarocks may not support this parameter at all (Support is added in luarocks 3.0.1)

On one linux host I have luarocks uses lua 5.1 and there was no need for this parameter.


## $ luarocks install ggram

> Error: Your user does not have write permissions in /usr/local/lib/luarocks/rocks
> you may want to run as a privileged user or use your local tree with --local.

Just add `--local` argument to the command:

`$ luarocks install --local ggram`

## $ luarocks install luasec

> luarocks install luasec — No file openssl/ssl.h

You need to install openssl

- Ubuntu: `apt install libssl-dev`, then retry command
- Mac: `brew install openssl`, then `luarocks install luasec OPENSSL_DIR=/opt/homebrew/opt/openssl@3`

## $ luarocks install luasocket

Ran into this on Ubuntu 20.04. I did not record the error itself

```sh
luarocks install luasocket
mkdir lua-build && cd lua-build
curl -R -O http://www.lua.org/ftp/lua-5.3.6.tar.gz && tar -zxf lua-5.3.6.tar.gz && cd lua-5.3.6
make linux test # You may need to sudo apt install make
make install
```

## $ lua bot.lua

> lua: bot.lua:5: module 'ggram' not found

This can happen if `luarocks install` was run with the `--local` parameter. In this case, you may need to tell the lua script where to look for modules. To do this, you need to add at the top of the bot file:

```lua
-- /home/ubuntu/.luarocks/share/lua/5.1
-- /\ you need to replace it with the path to the folder with the modules
-- You can find out by running luarocks show ggram
package.path = package.path
	.. ";/home/ubuntu/.luarocks/share/lua/5.1/?.lua"
	.. ";/home/ubuntu/.luarocks/share/lua/5.1/?/init.lua"
```
