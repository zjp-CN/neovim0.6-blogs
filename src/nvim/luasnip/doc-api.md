# API Reference

使用 `require("luasnip")` 所调用的函数。

本节不介绍该模块公有的各种节点构造函数，它们的用法在前面的章节或 [`Examples/Snippets.lua`] 中已介绍。

[`Examples/Snippets.lua` ]: https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua

## `add_snippets`

`add_snippets(ft:string or nil, snippets:list or table, opts:table or nil)`

在 `ft` 中提供 Snippets （代码片断列表）。

如果 `ft` 为 `nil`，则 Snippets 应该是一个包含片段的表，key 是相应的文件类型。

`opts` 可以有以下 key：
* `type`：`snippets`、 `"snippets"` 或 `"autosnippets"` 的类型
* `key`：标识本次调用添加的片段的 key。如果 `add_snippets` 调用已使用的 key，则删除上次调用的片段。这可以用来重新加载片断：给每个 `add_snippets` 
  传递一个唯一的 key，当片断发生变化时，只需重新调用 `add_snippets`。
  `over_priority`：为所有片断设置优先级。
* `default_priority`：只为没有优先级的片断设置优先级。

## `clean_invalidated`

`clean_invalidated(opts: table or nil) -> bool`

从内部片断存储中清除无效的代码片断。无效的片段仍然会被存储，但实际删除它们可能很有用，因为它们在展开过程中仍然需要迭代。
 
`opts` 可以包含：
* `inv_limit`：允许多少个失效的片段。如果无效代码片断的数量没有超过此阈值，则它们还不会被清理。少量无效的片段 
  （小于 100） 可能根本不会影响运行时，而重新创建内部片段存储可能会影响运行时。

## `get_id_snippet`

`get_id_snippet(id)`：返回对应 id 的代码片断。

## `in_snippet`

`in_snippet()`：如果光标位于当前片段内，则返回 true。

## `jumpable`

`jumpable(direction)`：如果当前节点有下一个 (direction = 1) 或上一个 (Direction = -1) 可跳转的节点，则返回 true。

## `jump`

`jump(direction)`：如果跳转成功，则返回 true。

## `expandable`

`expandable()`：如果片段可以在当前光标位置展开，则为 true。

## `expand`

`expand()`：在光标前展开片断。

## `expand_or_jumpable`

`expand_or_jumpable()`：返回 `expandable()` 或者 `jumpable(1)`，因为通常一个键同时用于向前跳转和展开。

## `expand_or_locally_jumpable`

`expand_or_locally_jumpable()`：与 `expand_or_jumpable()` 相同，但不同之处在于如果光标不在当前片段内，则忽略 jumpable。

## `expand_or_jump`

`expand_or_jump()`：如果跳转/展开成功，则返回 true。

## `expand_auto`

`expand_auto()`：在光标之前展开 autosnippet，如果在配置中设置了 `enable_autosnippets`，则不需要手动调用此函数，因为将通过 autocmd 自动调用。

## `snip_expand`

`snip_expand(snip, opts)`：在当前光标位置展开片段。 `opts` 可以包含：
* `clear_region`：在展开后跳入前要清除的文本区域。该文本区域必须在那一时刻传递给此函数，因为若在展开前清除，会用错误的值填充
  `TM_CURRENT_LINE` 和 `TM_CURRENT_WORD`（它们将错过片段触发器）；若展开后清除可能会移动光标下当前的文本，并使其不在 `i(1)`
  处结束，而是 `#trigger` 字符位于其右侧。用于清除的实际值是 `from` 和 `to`，这两个值都是 (0, 0) 
  开始索引的字节位置。如果变量不必填充正确的值，则可以手动删除文本。
* `expand_params`：table，用于覆盖片段中使用的 `trigger` 并设置 
  `captures`。这对于模式触发的节点非常有用，其中触发器必须从模式更改为触发节点的实际文本。传入 `trigger` 和 `captures`。
* `pos`：位置 `{line, col}`，从 (0, 0) 开始，单位为字节，由 `nvim_win_get_cursor()` 返回，在该位置应展开片段。片段将放在
  `(line, col-1)` 和 `(line, col)` 之间。如果 pos 为 nil，则在当前光标处展开片段。
* `jump_into_func`：`fn(snippet) -> node`。负责跳入片段。返回的节点被设置为新的活动节点，即它是下一次跳越的起点。默认值基本上是这个：
    ```lua
    function(snip)
    	-- jump_into set the placeholder of the snippet, 1
    	-- to jump forwards.
    	return snip:jump_into(1)
    ```

    而这个只能用来插入片段：
    ```lua
    function(snip)
    	return snip.insert_nodes[0]
    end
    ```

`opts` 本身和上述它的任何 key 都可以为 nil。

## `get_active_snip`

`get_active_snip()`：返回当前活动片段（不是节点）。

## `choice_active`

`choice_active()`：如果在 ChoiceNode 内，则为 true。

## `change_choice`

`change_choice(direction)`：将当前最活跃、最里层的 ChoiceNode 中的选项修改为向前 (direction = 1) 或向后 (direction = -1)。

## `unlink_current`

`unlink_current()`

从跳转列表中删除当前片段，并将当前节点设置在片段之后，如果不可能，则设置在其之前。

LuaSnip 无法自动检测到片段被删除等情况时非常有用。

## `lsp_expand`

在光标位置展开 lsp-syntax 定义的片段。

`opts` 可以与 [`snip_expand`](#snip_expand) 中的 `opts` 选项相同。

## `active_update_dependents`

`active_update_dependents()`

更新将当前节点作为 argnode 的所有 FunctionNode / DynamicNode。

实际上只会在任何 argnode 中的文本发生更改时更新它们。

## `available`

`available()`：返回当前文件类型定义的所有代码片断的表，格式为 `{ft1={snip1, snip2}, ft2={snip3, snip4}}`。

## `exit_out_of_region`

`exit_out_of_region(node)`：

检查光标是否仍在 node 所属的片段范围内。

如果是，则不发生任何更改；如果为否，则退出该片段，并对随后的片段区域进行检查和可能退出。

下一个活动节点将是在光标所在的节点前面的片段的 0 节点。

如果光标不在任何片段内，则活动节点将是跳转列表中的最后一个节点。

如果跳转出现错误（主要是因为删除了片段），则会从跳转列表中删除该片段。

## `store_snippet_docstrings`

`store_snippet_docstrings(snippet_table)`

将 `snippet_table` 中所有片段的文档字符串保存到一个文件 `stdpath("cache")/luasnip/docstrings.json`。
在添加或修改片断后调用 `store_snippet_docstrings(snippet_table)`，然后将所有片断添加到 `snippet_table`后，在启动时调用
`load_snippet_docstrings(snippet_table)`，这种方式能避免每次启动时重新生成（未改变的）文档字符串。

在依赖于文档字符串和加载 LuaSnip 的情况下，让它们延迟加载可能更明智，例如，就在需要它们之前调用此函数。

`snippet_table` 应该像 `luasnip.snippets` 一样布局，它很可能始终是 `luasnip.snippets`。

## `load_snippet_docstrings`

`load_snippet_docstrings(snippet_table)`

将 `snippet_table` 中所有片断的文档字符串从 `stdpath("cache")/luasnip/docstrings.json` 加载。

文档字符串通过触发器存储和恢复，这意味着如果一种文件类型的两个片段具有相同的内容（虽然在实际使用中不太可能发生），则可能会发生错误。

`snippet_table` 应按照 `store_snippet_docstrings` 中的说明进行布局。

## `unlink_current_if_deleted`

`unlink_current_if_deleted()`

检查当前片段是否被删除，如果已被删除，则将其从跳转列表中删除。

这不是 100% 可靠的，因为 LuaSnip 只看到 extmarks，并且它们的开始/结束可能不在同一位置，即使它们之间的所有文本都被删除了。

## `filetype_extend`

`filetype_extend(filetype:string, extend_filetypes:table of string)`

告诉 LuaSnip 对于带有 `ft=filetype` 的缓冲区，也应该搜索来自 `extend_filetyps` 的片段。

`extend_filetyps` 为 lua 数组 (`{ft1, ft2, ft3}`)。

`luasnip.filetype_extend("lua", {"c", "cpp"})` 将搜索并展开 lua 文件的 c 和 cpp 片段。

## `filetype_set`

类似于 `filetype_extend`，但在附加到文件类型后，然后设置它们。

如 `filetype_set("lua", {"c"})` 导致在 lua 文件中只展开 c 片断，甚至不搜索 lua 片断。

## `cleanup`

`cleanup()`：清除所有片段。仅在制作和测试片段时使用，对于常规使用没有用处。

## `refresh_notify`

`refresh_notify(ft:string)`

触发一个 autocmd，其他插件可以感知它来对刷新的文件类型执行各种清理。

可用来在文件类型 `ft` 添加了新片段时发送信号。

## `set_choice`

`set_choice(indx:number)`

更改为第 `indx` 个选项。

如果没有 ChoiceNode 处于活动状态，则抛出错误。

如果活动的 ChoiceNode 没有 `indx` 选项，则会抛出错误。

## `get_current_choices`

`get_current_choices() -> string[]`

返回多行字符串的列表。即使它只有一行也会列出。

第 `i` 个字符串对应于当前活动的 ChoiceNode 的第 `i` 个选项。

如果没有 ChoiceNode 处于活动状态，则抛出错误。

