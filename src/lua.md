# lua

## lua 基础语法

* <https://www.lua.org/manual/5.1/>: Lua 5.1 Reference Manual
* <https://zjp-cn.github.io/lua-note>: 我自己整理的 lua5.3（与 nvim [所需][why-lua5.1]的 5.1 不完全兼容）

[why-lua5.1]: https://github.com/neovim/neovim/wiki/FAQ#why-lua-51-instead-of-lua-53

## nvim 中的 lua 开发插件

* <https://github.com/rafcamlet/nvim-luapad>: Interactive real time neovim scratchpad for embedded lua engine - type and watch! ![](https://github.com/rafcamlet/nvim-luapad/raw/master/gifs/luapad_colors.gif)

## 使用 lua 编写插件

* [(Rafał, 2022.02) How to write neovim plugins in Lua](https://www.2n.pl/blog/how-to-write-neovim-plugins-in-lua)
* [(Rafał, 2022.06) How to make UI for neovim plugins in Lua](https://www.2n.pl/blog/how-to-make-ui-for-neovim-plugins-in-lua)

## LSP/FMT

* https://github.com/sumneko/lua-language-server
* https://github.com/CppCXY/EmmyLuaCodeStyle

```shell
# FMT
wget https://github.com/CppCXY/EmmyLuaCodeStyle/releases/latest/download/linux-x64.tar.gz
rm lua-formater -r
tar zxvf linux-x64.tar.gz
mv linux-x64 lua-formater

# LSP
# 需要修改版本号
wget https://github.91chi.fun/https://github.com//sumneko/lua-langua
ge-server/releases/latest/download/lua-language-server-3.3.1-linux-x64.tar.gz
rm lua-lsp -r
mkdir lua-lsp
tar zxvf lua-language-server-3.3.1-linux-x64.tar.gz -C lua-lsp

# 添加到环境
# ln -s /download/lua-lsp/bin/lua-language-server /usr/local/bin/lua-language-server
# ln -s /download/lua-formater/bin/CodeFormat /usr/local/bin/luafmt

# luafmt check -w . -d
# luafmt format -w . -d
```

```
# 项目根目录创建 .editorconfig 文件
[*.lua]
indent_size = 2
continuation_indent_size = 2
```
