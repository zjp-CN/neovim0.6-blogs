# Rust binding

## RPC lib

推荐 [nvim-rs](https://github.com/KillTheMule/nvim-rs)，它是
[neovim-lib](https://github.com/daa84/neovim-lib) 的 fork 版本，也是目前该方向最活跃的库。

案例：
* 【neovim-lib】<https://github.com/michaelb/sniprun>: A neovim plugin to run lines/blocs of code (independently of the rest of the file), supporting multiples languages

其他方案：[nvim-oxi](https://github.com/noib3/nvim-oxi)（Rust bindings to all things Neovim）。正在开发中，主要目的是将 Rust 代码编译成 so 文件以供 lua 调用。

## NeoVim doc

1. [channel](https://neovim.io/doc/user/channel.html#channel-intro)：或者 `:h channel`
2. [api](https://neovim.io/doc/user/api.html)：或者 `:h api`

> 技巧：使用 `<Ctrl-]>` 或 `<Ctrl-t>` 进入 tag 或者从 tag 返回。




## 相关文章

1. [Writing Neovim plugins in Rust](https://medium.com/@srishanbhattarai/a-detailed-guide-to-writing-your-first-neovim-plugin-in-rust-a81604c606b1)
