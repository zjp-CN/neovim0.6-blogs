# 行内搜索模式

> 官网：[https://github.com/rhysd/clever-f.vim](https://github.com/rhysd/clever-f.vim)

当你习惯使用 `f`、`F`、`t`、`T` 在一行内搜索/跳转字符，然后使用
`;` 或 `,` 往下/上搜索 ，那么你可以试试这个插件。

它可以让你忽略使用 `;` 或 `,` 的方式，而是直接继续按 `f` 或 `t` / `F` 或 `T` 往下/上搜索。

而且它做了一些细节上的增强：
- 搜索时高亮可跳转的字符
- 仅高亮下一可跳转的字符 `g:clever_f_mark_direct`，默认高亮当前行所有可跳转的字符
- 高亮超时 `g:clever_f_highlight_timeout_ms`，默认为光标移走时取消高亮
- 自定义高亮样式 `g:clever_f_mark_char_color`
- 严格的行内搜索 `g:clever_f_across_no_line`，默认当前行没有匹配的字符，则跨行搜索
- 忽略大小写或智能大小写搜索 `g:clever_f_ignore_case`/`g:clever_f_smart_case`
- 结束重复前一目标字符的超时 `g:clever_f_timeout_ms`
- 搜索前弹窗 `g:clever_f_show_prompt`
- 设置某符号来搜索所有符号，比如 `let g:clever_f_chars_match_any_signs='\\'` 可使 `f\` 搜索任何符号
