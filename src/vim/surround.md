# vim-surround

> 官网：[https://github.com/tpope/vim-surround](https://github.com/LunarWatcher/auto-pairs)

增删改 括号、引号、XML 标签 的利器。`i` 是为了编辑这些环境内的文字，而 `s` 就是为了编辑双侧环境。

以字符 `"Hello world!"` 为例，并且都在普通模式下（按 `Esc` ）

1. 增：
   - 对光标所在的单词（以空格或者标点符号隔开的内容）增加环境：光标移动在单词的一个字符上，按
     `ysiw` + `目标环境` （ `ysiw` 的记法：you surround in word），如
     光标移到 `H` 上，按 `ysiw)` 得到 `"(Hello) world!"`
   - 对一整行增加环境：光标移动在某一行，按 `yss` + `目标环境` ，如 `yss}` 、`yss<div>`
2. 删：
   - 光标移动在 `"Hello world!"` 任何一个字符上，输入`ds"` 就可把 `"` 删除 ，从而得到 `Hello world!`
   - 删除的方式从内到外，比如 `({ Hello } world!)` 删除 `{}` 和 `()` ，只需把光标移到
     `{ Hello }` 某个字符上，使用 `ds{ds(` （或者 `ds}ds)` 之类的）得到 `Hello world!` 
3. 改：修改单词或一行两边的环境：光标移动在 `"Hello world!"` 任何一个字符上，按 
   `cs`+ `当前环境` + `目标环境`  即可。例如：
   - 输入 `cs"'` 就可把 `"` 改成 `'` ，从而得到 `'Hello world!'`
   - 输入 `cs"]`就可把 `"` 改成 `]` ，从而得到 `[Hello world!]`
   - 输入 `cs"[`就可把 `"` 改成 `[ ` ，从而得到 `[ Hello world! ]`
   - 针对 xml tag，输入 `cs"<p>` 则得到 `<p>Hello world!</p>`

注意： `{}` `[]` `()` 三种括号在增、改的时候，左右环境是不一样的，
左环境会在单词左右两侧增加一个空格再放入环境中，右环境直接把单词放进环境里；
但是在删的时候使用左环境或者右环境都可以把环境删除。

相关讨论：[What does the "y" stand for in "ysiw"?](https://github.com/tpope/vim-surround/issues/128)
