# litee

## 打造轻型 IDE 体验的插件框架

目前，[litee.nvim](https://github.com/ldelossa/litee.nvim) 主要提供以下一些功能：

|                    | 主要功能（查看+跳转）               | 使用方式                                                                                             |
|--------------------|-------------------------------------|------------------------------------------------------------------------------------------------------|
| [litee-calltree]   | Call Hierarchy：函数/方法的调用层级 | `:lua vim.lsp.buf.incoming_calls()` 被调用情况 <br> `:lua vim.lsp.buf.outgoing_calls()` 内部调用情况 |
| [litee-symboltree] | 当前文件内符号层级情况              | `:lua vim.lsp.buf.document_symbol()`                                                                 |
| [litee-filetree]   | 当前目录下的文件层级                | `:LTOpenFiletree`、`:LTPopOutFiletree`                                                               |
| [litee-bookmarks]  | 书签                                | LTCreateBookmark / LTDeleteBookmark <br> LTListNotebooks / LTMigrateNotebooks                        |

[litee-calltree]: https://github.com/ldelossa/litee-calltree.nvim
[litee-symboltree]: https://github.com/ldelossa/litee-symboltree.nvim
[litee-filetree]: https://github.com/ldelossa/litee-filetree.nvim
[litee-bookmarks]: https://github.com/ldelossa/litee-bookmarks.nvim
