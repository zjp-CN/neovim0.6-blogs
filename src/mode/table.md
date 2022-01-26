# 表格模式

> 官网：[https://github.com/dhruvasagar/vim-table-mode](https://github.com/dhruvasagar/vim-table-mode)

花 7 分钟的时间，看看它的 demo，你会惊讶于在 vim 里面使用表格会如此有趣。

<a href="http://www.youtube.com/watch?v=9lVQ0VJY3ps"><img
src="https://raw.github.com/dhruvasagar/vim-table-mode/master/youtube.png"/></a>

如果：
- 你从头创建创建表格，或者编辑已有的表格，它可以在你输入 `|` 的时候自动处理对齐、补充横线、添加空隙。
- 你有一个格式良好的数据，你可以使用 `:Tableize` 把它转成表格。
- 你想在单元格之间跳转，它提供 motions：`[|`、`]|`、`{|`、`}|` 可以让你 左、右、上、下地移动光标。
- 你想操作单元格、行和列，你可以使用：
    - `i|` 和 `a|` 来描述单元格的内容
    - `<leader>tdd` 删除光标所在的行；当你输入 `2<leader>tdd`，删除光标所在行及其下 1 行
    - `<leader>tdc` 删除光标所在的列；当你输入 `2<leader>tdc`，删除光标所在列及其后 1 列
    - `<leader>tic` 在光标所在列后添加一列，而 `<leader>tiC` 则在列前添加一列；支持数字
    - 在换行之后输入 `||` 可插入分隔行
- [动态公式](https://github.com/dhruvasagar/vim-table-mode#formula-expressions)
