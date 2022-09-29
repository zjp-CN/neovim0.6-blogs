# quickfix 与文本处理

> 大部分内容整理自：[Advanced Vim topics, tips and tricks (by *Mark McDonnell*)](https://www.integralist.co.uk/posts/vim/)

## `global`

| 命令                                 | 功能                                              |
|--------------------------------------|---------------------------------------------------|
| `:global/pattern/excmd`              | 对满足 `pattern` 的行文本进行 `excmd` 操作        |
| `:g/^foo/d` 等价于 `:g/^foo/norm dd` | 删除 `foo` 开头的行（`g = global`，`d = delete`） |
| `:g!/^foo/d`                         | 删除不是 `foo` 开头的行                           |
| `:g/foo/norm @q \| update`[^table]   | 对含 `foo` 的行执行 `@q` 宏，并更新文本[^norm]    |
| `:g/^/exe "norm \<s-j>"`             | 每两行进行合并[^exe]                              |

[^table]: 注意：表格中的 `\|` 实际只需要输入 `|`。

[^norm]: [`norm`](https://vimhelp.org/various.txt.html#%3Anormal) 表示模拟 norm 模式下操作

[^exe]: [`execute`](https://vimhelp.org/eval.txt.html#%3Aexecute) 用于计算 Ex 命令的值，比如涉及控制键

## 内置的 `vimgrep`

| 项目全局替换                                      | 说明                                                                                                 |
|---------------------------------------------------|------------------------------------------------------------------------------------------------------|
| `:vimgrep /pattern/[gjf] path_to_file`            | `g` 一行内匹配所有（不使用表示一行只匹配第一次出现的）；`j` 不显示第一个匹配的内容；`f` 启用模糊查询 |
| `:vimgrep /pattern/[gjf] %`                       | 在当前文件中搜索：`%` 表示当前文件路径                                                               |
| `:vimgrep /pattern/[gjf] **/*`                    | 在当前项目中搜索                                                                                     |
| ``:vimgrep /ssh/j `find . -type f -name 'tmux*'`` | 使用 \`\` 来获取外部程序的结果：调用 `find` 程序来搜索文件名                                         |
| `:vimgrep /<C-r>// *`                             | `<C-r>/` 快捷键表示 `/` 寄存器（查询模式的寄存器）；在当前目录的第一层文件下搜索 `/` 寄存器的内容    |
 

* `vimgrep` 是全局（唯一）的，每次调用的结果替换上一次的结果；使用 `copen` 打开 quickfix 窗口，使用 `cnext` 跳转下一个，`cNext` 跳转上一个
* `lvimgrep` 是局部的（`l` 表示 location），每个 buffer 都可以有一个；`lopen`、`lnext`、`lNext` 在不同的 buffer 中独立地工作；几乎所有的 `vimgrep`
  都有一个相应的 `lvimgrep` 版本
* `vimgrepadd`、`lvimgrepadd` 使用方式与 `vimgrep` 也相同，表示不覆盖上一次结果，而是添加到上一次结果
* `cex[pr] expr` 和 `lex expr` 用于计算 expr 的值，并把结果放到 quickfix：
  * `:cexpr system('grep -n xyz *')` 调用 grep 程序的结果
  * `:cexpr getline(1, '$')` 当前 buffer 全文
  * `:cex []` 清空 quickfix 

## 外部的 `grep`

| 命令                                                                 | 功能                                                      |
|----------------------------------------------------------------------|-----------------------------------------------------------|
| `:set grepprg`                                                       | 查询当前 grep 程序；默认为 `grep -n $* /dev/null`         |
| `:set grepprg=rg\ --vimgrep \| :set grepformat=%f:%l:%c:%m,%f:%l:%m` | 设置为 rg                                                 |
| `:silent! noautocmd grep pattern % \| copen`                         | 不弹出搜索结果，并打开 quickfix，打开文件时不运行 autocmd |
| `:set grepprg=ag\ --nogroup\ --nocolor\ --skip-vcs-ignores`          | 设置为 ag                                                 |
| `:<range>!grep foo`                                                  | 只留下含 `foo` 的行（删除不含 `foo` 的行）                |
| `:<range>!grep -v foo`                                               | 只留下不含 `foo` 的行（删除含 `foo` 的行）                |

和 `vimgrep` 系列类似，`grep` 为全局 quickfix，局部的为 `lgrep`，全局增加的为 `grepadd`，局部增加的为 `lgrepadd`。

## `telescope`

许多插件提供将插件的搜索结果发送至 quickfix。这里介绍最常见的 [`telescope`] 的搜索功能。

首先启用历史记录快捷键：

```lua
-- 更多可设置快捷键的功能见 `:help telescope.actions`
local action = require 'telescope.actions'
local mappings = {
  i = { -- insert mode
    -- 上翻/下翻历史搜索记录：所有功能共享历史搜索记录
    ["<C-Down>"] = action.cycle_history_next,
    ["<C-Up>"] = action.cycle_history_prev,
  },
  n = { -- normal mode
    ["t"] = action.toggle_all, -- 反选所有
    ["T"] = action.drop_all, -- 取消所有
    ["d"] = action.delete_buffer,
    -- `<C-q>` clear + send all to quickfix
    -- `<A-q>` clear + send the selected to quickfix
    -- `a` add the selected to quickfix
    -- `A` add all to quickfix
    ["a"] = action.add_selected_to_qflist,
    ["A"] = action.add_to_qflist,
  }
}
require'telescope'.setup {
  defaults = {
    mappings = mappings,
  },
}
```

然后设置常见的一些快捷键来快速打开功能对话框：

```vim
nnoremap ,f <cmd>Telescope find_files<cr>
nnoremap ,l <cmd>Telescope live_grep<cr>
nnoremap ,g <cmd>Telescope grep_string<cr>
nnoremap ,b <cmd>Telescope buffers<cr>
nnoremap ,d <cmd>Telescope diagnostics<cr>
nnoremap ,q <cmd>Telescope quickfix<cr>
nnoremap ,Q <cmd>Telescope quickfixhistory<cr>
```

Normal 模式中按 `,g` 会在当前项目中搜索当前光标下的内容，弹出 telescope 对话框之后[^telescope-keymap]：
* 按 `<Ctrl-q>` 将所有内容发送至 quickfix
* 或者按 `<Tab>`/`<Shift-Tab>` 多选，按 `<Alt-q>` 把选择的内容发送至 quickfix

对 quickfix 处理内容常常使用 `cdo`（见下文）。此外 telescope 可直接操作已有的 quickfix：
* 按 `,q` 在 telescope 中打开 quickfix
* 基于已有的 quickfix 创建新的 quickfix，见上述发送至 quickfix 的两种步骤（这相当于从 quickfix 列表中减少条目）
* 映射 `action.add_selected_to_qflist` 和 `action.add_to_qflist` 等函数提供了添加新项至 quickfix 列表的功能
* 按 `,Q` 可查看和转到历史 quickfix 列表

`live_grep` 和 `grep_string` 使用的是 `telescope.defaults.vimgrep_arguments`，默认为 [`rg`] 且进行了一些配置，所以：
* 直接支持正则而无需额外转义，注意这使用了 Rust [`regex`] 库的正则语法
* 开启了 smart-case，输入小写字母时会查询该字母的大小写，而输入大写则只查询大写
* 如果你想使用其他搜索程序，可以自行配置 `defaults = { vimgrep_arguments = { ... }, mappings = mappings, }`

更多功能见 telescope 的[帮助文档][telescope-doc]。

[^telescope-keymap]: 使用 `<Ctrl-/>` 和 `?` 显示对话框在 Insert/Normal 模式下的快捷键映射。


[`rg`]: https://github.com/BurntSushi/ripgrep
[`regex`]: https://docs.rs/regex/latest/regex/#syntax
[`telescope`]: https://github.com/nvim-telescope/telescope.nvim
[telescope-doc]: https://github.com/nvim-telescope/telescope.nvim/blob/master/doc/telescope.txt

## 处理搜索结果

通常 `vimgrep` 和 `grep` 用于搜索内容，并通过 `copen`/`lopen` 把搜索结果（文件路径、位置信息、内容）放置于 quickfix。

然后使用 `<c|l>[f]do` 进行文本处理，区别在于：

* `cdo` vs `ldo`：全局操作 vs 局部（当前 buffer）操作
* `cdo` vs `cfdo`：全部操作 vs 对每个文件只操作一次

例子：

* `:cdo s/pat/replacement/` 把 `pat` 换成 `replacement`
* `:cdo undo` 撤销修改
* `:silent! noautocmd cdo ... | update` 执行操作文件时不运行 autocmd，并写入操作，整个过程不显示消息
  * `silent!` 忽略中途打印的消息（`mes` 也看不到），`!` 表示连错误消息也忽略
  * `noautocmd` 可以加快操作，因为无需运行自动命令
  * `update` 相当于 `:write`，但仅发生在文件修改之后写入（`:w` 无论有没有修改文件都会写入）
  * 建议至少使用 `:cdo ... | update` 形式，因为基于未保存的缓冲区修改可能引发数据竞争，如果需要撤销，使用 `:cdo undo | update` 即可
* `:cfdo %s/foo/bar/g` 对每个文件进行一次批量替换
  * 相比于 `cdo`，这减少了替换后写入的次数（每个文件最多只需写入一次），因此有时可以避免多次修改造成的意外/动态修改
  * 可以想象成，对 quickfix 列出的文件进行全局替换（嗯，类似于下面使用的 `:argdo`）
  * `:cfdo %s/foo/bar/g` 对每个文件进行一次批量替换
    * 每个文件内的所有 `foo` 被替换成 `bar`
    * `%` 寄存器访问当前文件名，对于每次更新了的缓冲区，`%` 都会以新的文件名更新寄存器
    * 注意 `:cfdo s/foo/bar/` 表示对每个文件第一次出现的那个 `foo` 替换成 `bar`
    * 注意 `:cfdo s/foo/bar/g` 表示对每个文件第一个出现在 quickfix 的那行的所有 `foo` 替换成 `bar`

`do` 系列还有 tabdo / windo / bufdo / argdo，使用方式类似，只是应用的范围不同。

## `args`

`:args` 主要作为 buffers 的子集。在众多打开的文件 (buffers) 中，选择其中一部分文件执行操作：
* `:args *.md` 打开所有 md 文件（注意，这搜索当前目录下的一级路径，如果需要递归，使用 `:args **/*.md`）
  * `:args <Tab>` 可以选择 buffer
  * ``:args `fd ...` `` 根据 `fd` 搜索结果打开文件
  * `:args ...` 每次执行这个操作意味着创建新的列表（所以不需要删除列表）
* `:args` 查看待操作的文件列表（注意不带任何参数）
* `:argadd`、`:argdelete`、`:argdedupe` 对文件进行增加、删除、去重
* `:argdo` 对这些文件进行操作（具体例子与 `:cdo` 差不多）

可以看到，`args` 并不需要 quickfix，而是基于文件操作，所以自然可以实现文件替换 `:argdo %s/foo/bar/g`。

## `Cfilter`

对于 quickfix，筛选是常见操作。vim 内置一个插件来处理，完整的基本过程是：

```vim
:vimgrep /vim/ **/*
:packadd cfilter
:Cfilter /\.md$/
```

这里打开一个 quickfix，加载 `cfilter` 插件，然后使用
* `:Cfilter /pat/` 筛选满足搜索模式的条目
* `:Cfilter! /pat/` 筛选不满足搜索模式的条目
* `colder` 前一个 quickfix，`cnewer` 后一个 quickfix
* `:Lfilter` 应用于 location list （quickfix 的 buffer 局部版本）
  * `lolder` / `lnewer` 前/后一个 location list

对于简单的筛选，这已经足够。唯一不足的是，似乎没有内置的条目删除命令。

## `nvim-bqf`

除了上述的 [`telescope`] 之外，你还可以使用 [`nvim-bqf`] 插件来增强 quickfix 的预览、删除、筛选操作[^add]，通常的步骤：
1. 通过 `<Tab>` 和 `<S-Tab>` 选择/反选一条或几条
2. `zn` 或 `zN` 将选中或没选中的条目创建新的 quickfix

[`nvim-bqf`]: https://github.com/kevinhwang91/nvim-bqf

[^add]: 增加到 quickfix 可使用 vim 内置的 vimgrepadd / lvimgrepadd / grepadd / lgrepadd 命令。

然后使用 `<c|l>[f]do` 对新的 quickfix 进行批量处理。

在预览方面，可搭配 `nvim-treesitter` 提供高亮。

在筛选方便，可搭配 `fzf` 提供模糊查询[^fzf]：
* `zf` 调出 fzf
* `<Tab>` 进行选择/反选
  * 在 visual mode 下可使用 `<Tab>` 多条选择/反选
  * 使用 `'<Tab>` 对光标所在的文件的所有条目进行选择/反选
  * 使用 `z<Tab>` 清除所有选择
* `zn` 把选中的条目创建新的 quickfix
  * `zN` 把未选中的条目创建新的 quickfix

[^fzf]: [`telescope`] 的搜索框直接支持模糊查询和预览，所以可以完全无需 `nvim-bqf` + `fzf`。

```lua
-- 安装 nvim-bqf
use {'kevinhwang91/nvim-bqf', ft = 'qf'}

-- optional
use {'junegunn/fzf', run = function() vim.fn['fzf#install']() end }

-- optional, highly recommended
use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
```

在支持 lsp 的许多地方也会使用到 quickfix：

* `vim.diagnostic.setqflist`、`vim.diagnostic.setloclist`
* `vim.lsp.buf.references()`
* `vim.lsp.buf.document_symbol()`
* `vim.lsp.buf.incoming_calls()`
* `vim.lsp.buf.outgoing_calls()`

所以 nvim-bqf 还算一个相对通用的插件。使用 telescope 还是 nvim-bqf 来管理 quickfix 完全是个人偏好。

## 自动化文本处理

nvim 完全可以当做命令行工具使用，所以对它进行自动化测试不麻烦。

以下操作对目录下的 md 文件进行文本替换并直接写入源文件，查看 diff，然后撤销写入。

```bash
nvim -u NONE --headless\
 +"
  :args *.md
  :args
  :silent! argdo %s/a/.../ge | update"\
 +"
  :!git diff
  :silent! argdo undo | update"\
 +":qa"
```

```diff
[a.md] aa.md  b.md
:!git diff
diff --git a/a.md b/a.md
index 705a2d7..a2db5c9 100644
--- a/a.md
+++ b/a.md
@@ -1,2 +1,2 @@
-abc
-aed
+...bc
+...ed
diff --git a/b.md b/b.md
index 4075523..86a1d9c 100644
--- a/b.md
+++ b/b.md
@@ -1,2 +1,2 @@
-aqwa
-ppa
+...qw...
+pp...
```
