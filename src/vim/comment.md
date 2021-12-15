# comment

> 官网：[https://github.com/preservim/nerdcommenter](https://github.com/preservim/nerdcommenter)

它的配置和快捷键较多，但很直观，使用起来不难。

比如以下配置

```vim
" Create default mappings
let g:NERDCreateDefaultMappings = 1
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = {'rust': {'left': '//', 'right': '', 'leftAlt': '///','rightAlt': ''}}
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1
" Specifies if trailing whitespace should be deleted when uncommenting
let NERDTrimTrailingWhitespace = 1
```

对于 `.rs` 文件，使用 `<leader>cc` 进行注释。默认以 `//` 方式注释。

使用 `<leader>ca` 在 `//` 和 `///` 注释方式中切换。

你可以在
[此处](https://github.com/preservim/nerdcommenter/blob/master/autoload/nerdcommenter.vim)
查看所有默认文件的注释符号。

其他同类型的插件：
- [tpope/vim-commentary](https://github.com/tpope/vim-commentary)
- [tomtom/tcomment_vim](https://github.com/tomtom/tcomment_vim)
