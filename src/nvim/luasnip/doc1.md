# LuaSnip

> 原文：<https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md>
>
> 例子：<https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua>

```
            __                       ____
           /\ \                     /\  _`\           __
           \ \ \      __  __     __ \ \,\L\_\    ___ /\_\  _____
            \ \ \  __/\ \/\ \  /'__`\\/_\__ \  /' _ `\/\ \/\ '__`\
             \ \ \L\ \ \ \_\ \/\ \L\.\_/\ \L\ \/\ \/\ \ \ \ \ \L\ \
              \ \____/\ \____/\ \__/.\_\ `\____\ \_\ \_\ \_\ \ ,__/
               \/___/  \/___/  \/__/\/_/\/_____/\/_/\/_/\/_/\ \ \/
                                                             \ \_\
                                                              \/_/
```

LuaSnip 是一个完全用 lua 编写的代码片段引擎。

它具有以下强大功能：根据用户输入插入文本 (`luasnip-function-node`) 或节点 (`luasnip-dynamic-node`)、
解析 LSP 语法和切换节点 (`luasnip-choice-node`) 等。关于映射和安装等基本设置，请查看 [README] 文件。

[README]: https://github.com/L3MON4D3/LuaSnip/blob/master/README.md

本帮助文档中的所有代码片段都假定

```lua
local ls = require "luasnip"
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require "luasnip.util.events"
local ai = require "luasnip.nodes.absolute_indexer"
local extras = require "luasnip.extras"
local fmt = extras.fmt
local m = extras.m
local l = extras.l
local postfix = require "luasnip.extras.postfix".postfix
```

# 基础

在 LuaSnip 中，代码片段由节点 (`nodes`) 组成。节点包括：

* `textNode`：静态文本
* `insertNode`：可编辑的文本
* `functionNode`：函数节点，可从其他节点的内容生成的文本
* 其他节点
  * `choiceNode`：在两个节点（或更多节点）之间进行选择
  * `restoreNode`：存储和恢复到节点的输入
* `dynamicNode`：动态节点，基于输入生成的节点

通常使用 `s(trigger:string, nodes:table)` 形式的函数创建代码片段。

这在 [片段](#片段) 一节中有更详细的解释，要点是它创建一个片段，该片段包含指定节点中的节点，然后调用
`expand` 时，如果光标前的文本与 `trigger` 匹配，则插入到缓冲区中。

给定文件类型的代码片断必须通过 `ls.add_snippets(filetype, snippets)` 添加进 LuaSnip。

应可全局访问（针对所有文件类型）的片段必须添加到特殊文件类型 `all`。

```lua
ls.add_snippets("all", {
	s("ternary", {
		-- equivalent to "${1:cond} ? ${2:then} : ${3:else}"
		i(1, "cond"), t(" ? "), i(2, "then"), t(" : "), i(3, "else")
	})
})
```

还可以使用 `ls.filetype_extend` 将一种文件类型的代码片段提供给另一种文件类型，更多参见 [api](#api)。

# 节点

每个节点都接受一个可选的参数列表作为它的最后一个参数。

有一些常见的，如 [`node_ext_opts`](#ext_opts)；也有一些只适用于某些节点，如针对函数和动态节点的 
`user_args`。这些可选的 `opts` 仅在节点接受非通用的选项时才会被提及。

# 片段

定义代码片段的最直接方式是 `s`：

```lua
s({trig="trigger"}, {})
```

（这段代码除了是一个最小的例子外，毫无用处。）

`s` 接收以下可能选项的表作为第一个参数：

| 选项        | 类型            | 默认值 | 说明                                                                                     |
|-------------|-----------------|--------|------------------------------------------------------------------------------------------|
| `trig`      | string          |        | 唯一必须提供的选项，触发的文字                                                           |
| `name`      | string          |        | 可用于 `nvim-compe` 等其他插件识别片段                                                   |
| `dscr`      | string 或 table |        | 片段的描述，多行时使用 `\n` 分隔的字符串或者表                                           |
| `wordTrig`  | boolean         | true   | true 时，片段只在光标前的字 (`[%w_]+`) 与 trigger 相符时展开                             |
| `regTrig`   | boolean         | false  | trigger 是否被解释成 lua 模式                                                            |
| `docstring` | string          |        | 片段的文本表示，类似于 `dscr`；覆盖从 json 中加载的 docstring                            |
| `docTrig`   | string          |        | 对于使用 lua 模式所触发的片段：定义用于生成 docstring 的 trigger                         |
| `hidden`    | boolean         | false  | 提示补全引擎：true 时，在查询片段时不应该展示该片段                                      |
| `priority`  | 正数            | 1000   | 片段的优先级：高优先级先于低优先级匹配触发；多个片段的优先级也可在 `add_snippets` 中设置 |

`s` 也可以只接收一个字符串，此时该字符串表示 `trig`，其他所有值为默认值：

```lua
s("trigger", {})
```

`s` 的第二个参数是一个表，其中包含属于该片段的所有节点。如果该表只有一个节点，则可以直接传递该节点，而无需将其包装在表中。

第三个参数 (`opts`) 是一个包含以下有效键的表：

| 选项                                         | 形式                                                    | 默认值           | 说明                                                                                                                                               |
|----------------------------------------------|---------------------------------------------------------|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| `condition`                                  | `fn(line_to_cursor, matched_trigger, captures) -> bool` | 返回 true 的函数 | 只有在函数返回 true 时，片段才会被展开。在以任何方式修改文本之前都会调用该函数。函数参数的含义：光标所在的行数、匹配的触发内容、捕获（表的形式）。 |
| `show_condition`                             | `f(line_to_cursor) -> bool`                             | 返回 true 的函数 | 该函数表示该片段是否包括在当前的补全候选列表中。[^condition-show_condition]                                                                        |
| `callbacks`                                  |                                                         |                  | 进入/离开该片段的节点时调用的函数。[^callbacks]                                                                                                    |
| `child_ext_opts`、<br>`merge_child_ext_opts` |                                                         |                  | 应用在片段子节点上的 [`ext_opts`][#ext_opts]。                                                                                                     |

[^condition-show_condition]: 这与 `condition` 不同，因为 `condition` 在片段展开时求值（因此有权访问匹配的触发器和捕获），而 `show_condition` 则由补全引擎在扫描可用的候选片段时求值。

[^callbacks]: 例如，要在进入代码片段的第二个节点时打印文本，这样设置：
  ```lua
  {
  	-- position of the node, not the jump-position!!
  	-- s("trig", {t"first node", t"second node", i(1, "third node")}).
  	[2] = {
  		[events.enter] = function(node, _event_args) print("2!") end
  	}
  }
  ```
  如果要为片段自身的事件注册回调，可以使用键 `[-1]`。有关应用见[此处][#here]。

[#here]: #here

[#ext_opts]: #ext_opts

这个 `opts` 表也可以传递给 `snippetNode` 或 `indentSnippetNode`，但那里只使用 `callbacks` 和 `ext_opts` 相关的选项。

此外，代码片段有一些有趣的表，例如，`snippet.env` 包含 LSP 协议中使用的变量，如 `TM_CURRENT_LINE`、 `TM_FILENAME`、 
`snippet.captures`，其中存储了正则触发器的捕获组；用于触发片段的字符串存储在 `snippet.trigger` 中。

这些变量/表主要在动态/函数节点中有用，可以通过传递给函数的直接父节点 (`parent.snippet`) 访问片段。

`invalidate()`：调用此方法可以有效地移除片段。该片段将不再能够通过 `expand` 或 `expand_auto`
展开，它也将从列表中隐藏（至少在创建列表的插件考虑了 `hidden` key
的情况下），但可能需要在使片段失效后调用 `ls.refresh_notify(ft)`。

# TextNode

最简单的节点类型；只是文本。

```lua
s("trigger", { t("Wow! Text!") })
```

此片断将展开为

```
    Wow! Text!⎵
```

其中，⎵ 是光标。多行字符串可以通过传递行表而不是字符串来定义：

```lua
s("trigger", {
	t({"Wow! Text!", "And another line."})
})
```

# InsertNode

这种节点包含可编辑的文本，并且可以跳进和跳出（例如传统的占位符，像 textmate-snippets 中的 `$1`）。

该功能最好通过一个示例进行演示：

```lua
s("trigger", {
	t({"After expanding, the cursor is here ->"}), i(1),
	t({"", "After jumping forward once, cursor is here ->"}), i(2),
	t({"", "After jumping once more, the snippet is exited there ->"}), i(0),
})
```

![InsertNode](./InsertNode.gif)

1. 展开后，光标位于 InstertNode 1
2. 跳跃后，将位于 InsertNode 2
3. 再次跳跃后，将位于 InsertNode 0

如果在片段中未找到第 0 个 InsertNode，则会在所有其他节点之后自动插入一个。

跳转的顺序不必遵循节点的"文本"顺序：

```lua
s("trigger", {
	t({"After jumping forward once, cursor is here ->"}), i(2),
	t({"", "After expanding, the cursor is here ->"}), i(1),
	t({"", "After jumping once more, the snippet is exited there ->"}), i(0),
})
```

上述片段的行为如下所示：

1. 展开后，光标位于 InsertNode 1
2. 跳跃后，将位于 InsertNode 2
3. 再次跳跃后，将位于 InsertNode 0

一个重要的细节：因为 LuaSnip 与其他代码片段引擎不同，跳转位置在嵌套片段中的 1 处重新开始：

```lua
s("trigger", {
	i(1, "First jump"),
	t(" :: "),
	sn(2, {
		i(1, "Second jump"),
		t" : ",
		i(2, "Third jump")
	})
})
```

![InsertNode2](./InsertNode2.gif)

与 TextMate 语法不同，在 TextMate 语法中，制表符是全局的：

```snippet
${1:First jump} :: ${2: ${3:Third jump} : ${4:Fourth jump}}
```

当然，这不是完全相同的片段，但尽可能接近。

重新开始的规则仅在 Lua 中定义片段时生效，上面的 TextMate 片段将正确展开。

可以在 InsertNode 中包含初始文本，这对于潜在地保留一些默认值是很方便的：

```lua
	s("trigger", i(1, "This text is SELECTed after expanding the snippet."))
```

此初始文本的定义方式与文本节点相同，也可以（使用表）多行。

`i(0)` 可以有初始初始文本，但请注意，当所选文本被替换时，替换之后不会在 `i(0)` 
处结束，而是在它后面结束（原因见 [issue#110](https://github.com/L3MON4D3/LuaSnip/issues/110)）。

# FunctionNode

FunctionNode （函数节点） 根据其他节点的内容，使用自定义的函数来插入文本：

```lua
  s("trig", {
    i(1),
    f(
      function(args, snip, user_arg_1) return user_arg_1 .. args[1][1] end,
      { 1 },
      { user_args = { "Will be appended to text from i(0)" } }
    ),
    i(0)
  })
```

![FunctionNode](./FunctionNode.gif)

`f` 的第一个参数是函数，其参数为：

1. `args` 为当前节点所包含的文本表，如 `{line1}，{line1, line 2}}`。从第一行之后将删除所有片段行的缩进。

2. `snip` 为函数节点的直系父节点。它能轻松访问函数节点中可能有用的任何内容，即 `parent.snippet.env`
  或 `parent.snippet.captures` （后者包含触发 regex 的片段的捕获组）。在大多数情况下，`parent.env`
  是有效的。但如果函数节点嵌套在 SnippetNode 中，则直系父节点 SnippetNode 既不包含 `captures`，也不包含
  `env`，此时它们只存储在 `snippet` 中，可以通过 `parent.snippet` 访问到。

3. `user_args` 是可选的。注意，可能存在多个，例如，`user_args1, ..., user_argsn`，即 `function(args, snip, user_arg_1, ..., user_argn)`。

函数 `f` 需返回一个字符串，它将按原样插入；或者返回多行字符串的表，此时第一行后面的所有行都将在开头缩进。

`f` 的第二个参数是将其文本传递给函数的可跳转节点的索引表：
* 该表为空时，函数 `f` 在片段展开时计算一次
* 该表只有一个节点时，则可以直接传递该节点，而无需将其包装在表中
* 可以使用数字将索引指定为相对于函数节点的父级，也可以使用 [`absolute_indexer`] 指定为绝对索引

[`absolute_indexer`]: #absolute_indexer

与任何节点一样，最后一个参数是可选的。

`f` 接受的额外参数是 `user_args`，这是一个传递给函数的值表，目的是更容易地重复使用函数节点函数：

```lua
local function reused_func(_, _, user_arg1)
	return user_arg1
end

s("trig2", {
    f(reused_func, {}, { user_args = { "text " } }),
    f(reused_func, {}, { user_args = { "different text" } }),
})
```

![FunctionNode](./FunctionNode2.gif)

示例：使用函数节点从regex触发器中使用捕获：

```lua
s({trig = "b(%d)", regTrig = true},
	f(function(args, snip) return
		"Captured Text: " .. snip.captures[1] .. "." end, {})
)
```

![FunctionNode](./FunctionNode3.gif)

传递给函数节点的表：

```lua
s("trig3", {
	i(1, "text_of_first "),
	i(2, {"first_line_of_second", "second_line_of_second"}),
	f(function(args, snip)
		--here
        return " end"
	end, {2, 1} )})
```

![FunctionNode](./FunctionNode4.gif)

在 `--here` 处，`args` 将如下所示（前提是展开后未更改文本）：

```lua
args = {
	{"first_line_of_second", "second_line_of_second"},
	{"text_of_first "}
}
```

所以：

```lua
s("trig4", {
  i(1, "text_of_first "),
  i(2, { "first_line_of_second", "second_line_of_second", "" }),
  f(
    -- order is 2,1, not 1,2!!
    function(args, snip) return args[1][1] .. " " .. args[1][2] .. args[2][1] .. " end" end,
    { 2, 1 }
  )
}),
```

![FunctionNode](./FunctionNode5.gif)

再举一个例子来说明 `absolute_indexer` 的用法：

```lua
s("trig5", {
  i(1, " text_of_first "),
  i(2, { " first_line_of_second ", " second_line_of_second " }),
  f(function(args, snip)
    return args[1][1] .. args[1][2] .. args[2][1]
  end, { ai[2], ai[1] }) }),
```

![FunctionNode](./FunctionNode6.gif)

如果该函数仅对文本执行简单操作，请考虑使用 [`luasnip.extras`][extras] 中的`lambda`。

[extras]: #extras

# Postfix

后缀片段是一种在片段触发之前更改文本的片段类型，它著名地用于 [rust analyzer](https://rust-analyzer.github.io/)
和各种 IDE 中。虽然可以使用 regTrig 代码片段来实现这些功能，但后缀片段在大多数情况下使该过程变得更容易。

最简单的示例将 `.br` 前面的文本使用方括号 `[]` 括起来，如下所示：

```lua
postfix(".br", {
  f(function(_, parent)
    return "[" .. parent.snippet.env.POSTFIX_MATCH .. "]"
  end, {}),
})
```

`xxx.br` 将触发并展开为 `[xxx]`。

![postfix](./postfix.gif)

后缀片段是一种在片段触发之前更改文本的片段类型，它著名地用于 rust analyzer 和各种 IDE 中。虽然可以使用 regTrig 代码片段来实现这些功能，但后缀片段在大多数情况下使该过程变得更容易

注意函数节点中的 `parent.snippet.env.POSTFIX_MATCH`，它是后缀片段生成的额外字段。

此字段通过从触发器之前使用可配置的匹配字符串来提取匹配的文本来生成。

在上面的例子中，该字段为 `"xxx"`。这在动态节点中也是可用的。

此字段还可以在 lambda 和动态节点中使用。

```lua
postfix(".brl", {
  l("[" .. l.POSTFIX_MATCH .. "]"),
})
```

```lua
postfix(".brd", {
  d(1, function (_, parent)
    return sn(nil, {t("[" .. parent.env.POSTFIX_MATCH .. "]")})
  end)
})
```

![postfix](./postfix2.gif)

`postfix` 的参数与 `s` 的[参数](#片段)相同，但有一些额外的选项。

The first argument can be either a string or a table. If it is a string, that
string will act as the trigger, and if it is a table it has the same valid keys
as the table in the same position for `s` except:

第一个参数可以是字符串，也可以是表。

如果是字符串，则该字符串将用作触发器;如果是表，则它与
`s` 在相同位置的表具有相同的有效键，除了：

* `wordTrig`：传入时将忽略该键，因为后缀片段必须始终为 false
* `match_pattern`：触发前一行所匹配的模式，默认匹配模式为 `"[%w%.%_%-]+$"`。注意这里的
  `$`。这是因为只有直到触发开始的那一行才与模式匹配，这使得紧跟在触发器之前的字符作为字符串的结尾进行匹配。

一些其他匹配字符串，包括默认字符串，可以从后缀模块 `require("luasnip.extras.postfix).matches` 获得：

* `default`: `[%w%.%_%-%"%']+$`
* `line`: `^.+$`

第二个参数与 `s` 的第二个参数相同，即节点表。

可选的第三个参数与 `s` 的第三个可选参数相同，但有一个区别：

后缀片段通过片段的展开前事件的回调 (`pre_expand`) 来工作。如果你传递一个展开前事件的回调，那么它将在内置回调之后运行。

这意味着你的回调函数也可以访问 `POSTFIX_MATCH` 字段。

```lua
{
  callbacks = {
    [-1] = {
      [events.pre_expand] = function(snippet, event_args)
        -- function body to match before the dot
        -- goes here
      end
    }
  }
}
```

# ChoiceNode

ChoiceNode 允许在多个节点之间进行选择。

> 可设置快捷键来切换选项（lua 版本的选项切换快捷键设置往下看）；
>
> ```vim
> " For changing choices in choiceNodes (not strictly necessary for a basic setup).
> imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
> smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
> ```

```lua
s("trig6", c(1, {
  t("Ugh boring, a text node"),
  i(nil, "At least I can edit something now..."),
  f(function(args) return "Still only counts as text!!" end, {})
}))
```

![ChoiceNode](./ChoiceNode.gif)

与任何可跳转的节点一样，`c()` 的：
* 第一个参数是它在跳转列表中的位置。
* 第二个参数是包含节点的表，即选项。该表可以包含单个或多个节点。多个节点情况下，该表将被转换为 `SnippetNode`。
* 第三个参数是具有以下键的选项表：
    * `restore_cursor`：默认为 `false`。如果设置了该选项，并且正在编辑的节点也出现在切换到的选项中（
    `RestoreNode` 在两个选择中时发生这种情况）,那么光标将恢复到该节点。
    默认为 `false`，是因为启用可能会导致较差的性能。可以通过以下方法覆盖默认值：将 ChoiceNode 
    构造函数包装在另一个函数中，该函数将 `opts.restore_cursor` 设置为 `true`，然后使用它来构造
    ChoiceNode：
  ```lua
  local function restore_cursor_choice(pos, choices, opts)
      if opts then
          opts.restore_cursor = true
      else
          opts = {restore_cursor = true}
      end
      return c(pos, choices, opts)
  end
  ```

通常期望索引作为其第一个参数的可跳转节点在 ChoiceNode 内不需要索引；它们的索引与 ChoiceNodes 相同。

由于（目前）只能从 ChoiceNode 中更改选项，因此请确保所有选项都有一些位置可供光标停留。

这意味着在 `sn(nil, {...nodes...})` 中 `nodes` 必须包含一个 `i(1)`，否则 LuaSnip 只会"跳过"节点，从而无法更改选择。

```lua
c(1, {
	t"some text", -- textNodes are just stopped at.
	i(nil, "some text"), -- likewise.
	sn(nil, {t"some text"}) -- this will not work!
	sn(nil, {i(1), t"some text"}) -- this will.
})
```

通过调用 `ls.change_choice(1)` (向前) 或 `ls.change_choice(-1)` (向后) 来更改 ChoiceNode 的当前选择，例如

```lua
-- set keybinds for both INSERT and VISUAL.
vim.api.nvim_set_keymap("i", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("s", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("i", "<C-p>", "<Plug>luasnip-prev-choice", {})
vim.api.nvim_set_keymap("s", "<C-p>", "<Plug>luasnip-prev-choice", {})
```

除此之外，还有一个[选取器][picker]，任何选择都可以直接通过 `vim.ui.select` 立即选择。

[picker]: #select_choice

# SnippetNode

SnippetNode 直接将其内容插入到周围的片段中。

这对于仅接受一个子节点的 ChoiceNode 或在运行时创建节点并插入的 DynamicNode 非常有用。

SnippetNode 类似于一般的片段，需要指定何时展开的表；也类似于 InsertNode，需要一个数字，因为它也是可跳转的：

```lua
s("trig7", sn(1, {
  t("basically just text "),
  i(1, "And an insertNode.")
}))
```

![SnippetNode](./SnippetNode.gif)

注意，SnippetNode 不需要 `i(0)`。

# IndentSnippetNode

默认情况下，所有节点的缩进深度至少与触发文本相同。

使用 IndentSnippetNode 则可以覆盖该行为，注意传递给 `isn` 的空字符串：

```lua
s("isn", {
	isn(1, {
		t({"This is indented as deep as the trigger",
		"and this is at the beginning of the next line"})
	}, "")
})
```

![IndentSnippetNode](./IndentSnippetNode.gif)

仅在换行符之后应用缩进，因此不可能在使用 `isn` 触发的行上删除缩进（这可以通过匹配器内容之前的整行的 regex 触发器来实现）。

另一个很好的用法是在片段的节点之前插入文本，例如 `//` 或其他一些注释字符串：

```lua
s("isn2", {
	isn(1, t({"//This is", "A multiline", "comment"}), "$PARENT_INDENT//")
})
```

![IndentSnippetNode](./IndentSnippetNode2.gif)

`This is` 之前的 `//` 很重要，因为缩进只在换行符之后应用。

要启用这种用法，indentstring 中的 `$PARENT_INDENT` 将替换为父代的缩进。

# DynamicNode

非常类似于 FunctionNode，但 DynamicNode 返回的是一个片段节点，而不仅仅是文本，这使得它非常强大，因为片段的一部分可以根据用户输入进行更改。

DynamicNodes 构造函数的基本形态为 `d(position:int, function, argnodes:table of nodes, opts: table)`：

1. `postion`：就像所有可跳转的节点一样，表示这个节点跳转到的地方。
2. `function`：签名为 `fn(args，parent，old_state，user_args1，...，user_argsn)-> SnippetNode`，
  当 args 的文本发生变化时，调用该函数。此函数返回应该插入到 DynamicNodes 位置的节点（包装在一个 SnippetNode中）。动态节点所依赖的节点的
  `args`、`parent` 和 `user_args` 在 [FunctionNode] 部分也解释了。
    * `args`：文本的表，如 `{"node1line1", "node1line2"}, {"node2line1"}}` 
    * `parent`： DynamicNode 的直系父级
    * `old_state`：用户自定义的表。此表可以包含任何内容，目的是保存来自先前生成的 SnippetNode 的信息：如果 DynamicNode
      依赖于其他节点，则可能会重新构造它，这意味着用户对前一个 DynamicNode 的所有输入（比如 IntertNodes 中的文本、更改的 ChoiceNode）都将丢失。
      `old_state` 必须存储在函数返回的 SnippetNode 中，即 `SnippetNode.old_state`。下面的第二个示例说明了怎么使用 `old_state`
    * `user_args1, ..., user_argsn`：通过 DynamicNode 可选参数 (`opts`) 传递进来
3. `argnodes`：DynamicNode 所依赖的节点索引：如果其中任何一个触发更新，则执行 DynamicNode 函数，并将结果插入到 DynamicNode 
   处。可以是单个索引，也可以是索引表。
4. `opts`：和 FunctionNode 一样， DynamicNode 还接受 `user_args`。示例：

[FunctionNode]: #FunctionNode

```lua
s("trig8", {
  t "text: ", i(1), t { "", "copy: " },
  d(2, function(args)
    -- the returned snippetNode doesn't need a position; it's inserted
    -- "inside" the dynamicNode.
    return sn(nil, {
      -- jump-indices are local to each snippetNode, so restart at 1.
      i(1, args[1])
    })
  end,
    { 1 })
})
```

![DynamicNode](./DynamicNode.gif)

这个 DynamicNode 插入复制第一个 IntertNode 中的文本。

```lua
local function count(_, _, old_state)
  old_state = old_state or {
    updates = 0
  }

  old_state.updates = old_state.updates + 1

  local snip = sn(nil, {
    t(tostring(old_state.updates))
  })

  snip.old_state = old_state
  return snip
end

...

s("trig9", {
  i(1, "change to update"),
  d(2, count, { 1 })
})
```

![DynamicNode](./DynamicNode2.gif)

此片段将以 `"1\n Sample Text"` 开头，如果将 1 更改 3，它将更改为 `"3\n Sample Text\n Sample Text"`。

当更改为更大的数字时，插入到任何 DynamicNode 节点中的文本将被保留。

`old_state` 不再是跨多个重新创建保存用户输入的最佳方式：简短解释的 RestoreNode 对用户更加友好。

# RestoreNode

该节点可以存储和恢复由用户修改（如更改的选择、插入的文本）的片段节点。它的用法最好用一个例子来说明：

```lua
s("paren_change", {
	c(1, {
		sn(nil, { t("("), r(1, "user_text"), t(")") }),
		sn(nil, { t("["), r(1, "user_text"), t("]") }),
		sn(nil, { t("{"), r(1, "user_text"), t("}") }),
	}),
}, {
	stored = {
		user_text = i(1, "default_text")
	}
})
```

![RestoreNode](./RestoreNode.gif)

这个例子中，在更改选项时会保留输入到 `user_text` 中的文本。

RestoreNodeNode 的构造函数 `r` 最多有三个参数：

* `pos`：何时跳转到该节点
* `key`：标识哪些 Rest oreNode 应该共享其内容。
* `nodes`： RestoreNode 的内容。可以是单个节点，也可以是一个节点表（这两种节点都会被包装在一个 SnippetNode
  中，除非单个节点已经是一个 SnippetNode）。给定一个 key，其内容可以定义多次，但如果内容不同，则实际使用的内容是未定义的。如果
  ket 内容是在 DynamicNode 中定义的，则不会用于该 DynamicNode 之外的 Rest oreNode。绕过这一限制的一种方法是在 DynamicNode 
  之外的 RestoreNode 中定义内容。

key 的内容也可以在片段构造函数的可选参数 `opts` 中定义，如上例所示。

`stored` 表接受的值与 `r` 的 `nodes` 参数相同。如果没有为 key 定义内容，则默认为空的 IntertNode。

RestoreNode 的一个重要限制是，对于给定的 key，一次只能看到一个 key。有关详细信息，见 [issues#234]。

[issues#234]: https://github.com/L3MON4D3/LuaSnip/issues/234

RestoreNode 还可用于存储跨 DynamicNode 更新的用户输入。以下代码：

```lua
local function simple_restore(args, _)
	return sn(nil, {i(1, args[1]), i(2, "user_text")})
end

s("rest", {
	i(1, "preset"), t{"",""},
	d(2, simple_restore, 1)
})
```

![RestoreNode](./RestoreNode2.gif)

每次更改外部片段中的 `i(1)` 时，DynamicNode 内的文本被重置为 `"user_text"`。这可以通过使用 RestoreNode 来防止重置：

```lua
local function simple_restore(args, _)
	return sn(nil, {i(1, args[1]), r(2, "dyn", i(nil, "user_text"))})
end

s("rest2", {
	i(1, "preset"), t{"",""},
	d(2, simple_restore, 1)
})
```

![RestoreNode](./RestoreNode3.gif)

现在，输入的文本已存储。

RestoreNode 的缩进暂时不受 IndentSnippetNodes 的影响。如果这真的让你感到困扰，你可以新开一个问题。

# Absolute_Indexer

`absolute_indexer` 可用于将节点文本传递给不与其共享父节点的函数或动态节点。

正常情况下，不能从内部访问外部的 `i(1)`，例如嵌套在 ChoiceNode 中的 SnippetNode：

```lua
s("trig_ai", {
  i(1), c(2, {
    sn(nil, {
      t "cannot access the argnode :(",
      f(function(args) return args[1] end, { 1 })
    }),
    t "sample_text"
  })
})
```

使用 `absolute_indexer`：

```lua
s("trig_ai2", {
  i(1), c(2, {
    sn(nil, {
      t "can access the argnode :)",
      f(function(args) return args[1] end, { ai[1] })
    }),
    t "sample_text"
  })
}),
```

![AbsoluteIndexer](./AbsoluteIndexer.gif)

找节点的位置有一些特殊之处：

```lua
s("trig", {
  i(2), -- ai[2]: indices based on insert-order, not position.
  sn(1, { -- ai[1]
    i(1), -- ai[1][1]
    t "lel", -- not addressable.
    i(2) -- ai[1][2]
  }),
  c(3, { -- ai[3]
    i(nil), -- ai[3][1]
    t "lel", -- ai[3][2]: choices are always addressable.
  }),
  d(4, function() -- ai[4]
    return sn(nil, { -- ai[4][0]
      i(1), -- ai[4][0][1]
    })
  end, {}),
  r(5, "restore_key", -- ai[5]
    i(1)-- ai[5][0][1]: restoreNodes always store snippetNodes.
  ),
  r(6, "restore_key_2", -- ai[6]
    sn(nil, { -- ai[6][0]
      i(1) -- ai[6][0][1]
    })
  )
})
```

特别要注意的是，DynamicNode 的索引不同于生成的 SnippetNode 的索引，并且 RestoreNode （内部）总是存储一个
SnippetNode，因此即使 RestoreNode 只包含一个节点，该节点也必须能作为 `ai[RestoreNodeIndx][0][1]` 被访问到。

`absolute_indexer` 可以有不同的构造方式：

```lua
ai[1][2][3] == ai(1, 2, 3) == ai{1, 2, 3}
```


