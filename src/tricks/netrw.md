# netrw

> 原文：[Usando Netrw, el navegador de archivos nativo de vim](https://vonheikemen.github.io/devlog/es/tools/using-netrw-vim-builtin-file-explorer/)

你知道 Vim 有一个文件资源管理器吗？这是一个 Vim 自带的插件，它叫 Netrw。而且它不是很受欢迎，至少如果与 NERDtree 之类的东西比较。

出现这种情况的原因可能包括：
1. 不太直观
2. 有一些恼人的限制
3. 看起来并不酷

今天，我们将学习如何使用它，如何绕过这些限制，并在这个过程中，将把它变成更直观、更容易使用的东西。

## 初识 Netrw

让我们快速浏览进行探索。先尝试使用 Vim 打开一个目录（类似于 `vim .`）。如果你没有高度定制过 `vimrc`，Netrw 应该是这样的：

![](https://res.cloudinary.com/vonheikemen/image/upload/v1609938838/devlog/using-vim-netrw/netrw-full-screen_2021-01-06_09-13-11.png)

首先看到的是一个横幅 (banner)，上面有关于当前目录的信息。它向我们展示：

* 有关 Netrw 的信息、名称和版本 (V156)
* 当前目录的路径
* 对文件进行排序的依据，在本例中是按名称排序
* 另一个排序依据：按后缀赋予文件的优先级
* “快速帮助”：一些有关 Netrw 可以执行的操作的提示

有趣的是，你实际上可以与横幅中的一些“选项”进行交互。如果你把光标放在显示“已排序”(sorted) 的行上，然后按 `Enter`
键，将更改文件的顺序。你可以按名称、上次更新、大小或文件扩展名对它们进行排序。快速帮助可以为你显示一些常见任务的按键映射。

在横幅之后，有目录和文件。`../` 为父目录，`./` 为当前目录。最后有完美分类后的文件。

## 用法

现在，你已经了解了 Netrw 的外观，接下来介绍一下它的一些基本功能。

### 如何调用它

我们的第一站是 `:Explore` 命令。不带参数使用它将显示正在编辑的文件的目录。

如果你不想这样做，可以给它提供想要的目录的路径。根据你的 Vim 配置，特别是 `hidden` 选项，它会做不同的事情。

如果关闭 `hidden`（这是默认设置），并且当前文件中没有未保存的更改，则 `:Explore` 会让 Netrw 
占据整个窗口。如果文件中确实有未保存的更改，它将创建一个水平拆分，并在上方窗口中显示 Netrw。

![](https://res.cloudinary.com/vonheikemen/image/upload/v1609951259/devlog/using-vim-netrw/netrw-half-screen_2021-01-06_12-39-50.png)

> 如果你想要垂直拆分，可以使用 `:Explore!` 命令。

如果启用了 `hidden`，Netrw 将始终占据整个窗口。

现在谈谈已有的一些 `:Explore` 变体。

| Explore     | 创建目录的窗口位置                        |
|-------------|-------------------------------------------|
| `Hexplore`  | 水平拆分后的下方                          |
| `Hexplore!` | 水平拆分后的上方                          |
| `Vexplore`  | 垂直拆分后的左侧                          |
| `Vexplore!` | 垂直拆分后的右侧                          |
| `Sexplore`  | 垂直拆分后的下侧                          |
| `Sexplore!` | 水平拆分后的左侧                          |
| `Lexplore`  | 垂直拆分后的左侧，再次调用后收起 (toggle) |
| `Lexplore!` | 垂直拆分后的右侧，再次调用后收起 (toggle) |
| `Texplore`  | 新的选项卡 (tab)                          |
| `Rexplore`  | 从/到 Explore                             |

> 见 [asciinema](https://asciinema.org/a/Fa9y0AieDUImMHZjUbjKzjlwn) 如何使用 `Lexplore`。

### 导航

如果你想在目录和文件之间移动，需要知道以下按键映射：

* `Enter`：打开目录或文件
* `-`：转到上级目录
* `u`：返回历史的上一个目录
* `gb`：跳到最近保存在书签里的目录。要创建书签，使用 `mb`

### 文件操作

现在让我们看看如何对文件执行一些最常见的操作。

* `p`：打开预览窗口
* `<C-w>z`：先按 `Ctrl+w`，然后按 `z`。关闭预览窗口
* `gh`：切换隐藏文件（和目录，包括本级和上级目录）
* `%`：创建文件。好吧，它实际上不会，因为它只是给了你一个机会去创造一个。当你按 `%` 时，Vim 
  会询问文件名，然后让你编辑它。输入名称后，你需要保存文件（使用 `:write`）来真正创建它。
* `R`：重命名文件
* `mt`：指定“目标目录”，用于移动和复制（到何处, mark to）
* `mf`：标记文件或目录（来源, mark from）。对多个文件执行的任何操作都取决于这些标记。因此，如果你想要复制、移动或删除文件，你需要对它们进行标记
* `mc`：复制标记的文件到目标目录
* `mm`:将标记的文件移进目标目录
* `mx`：对标记的文件运行外部命令
* `D`：删除文件或空目录。Vim 不允许我们删除非空目录。稍后将展示如何绕过这个限制
* `d`：创建目录

### 对多个文件执行操作

在阅读了这些按键映射后，我打赌你会想知道一个人是如何复制或移动文件的。我将给出一个移动一些文件的例子。分三步走：

* 指定目标目录 `mt`
* 标记要移动的文件 `mf`
* 运行适当的命令，在我们的例子中是 `mm`

> 见 [asciinema](https://asciinema.org/a/YkvegGilPQpSbABrOcFZYhN7W)。

以下是演示中发生的情况：

* *00:00-00:17* 用 `:Explore` 打开 Netrw。然后检查 `test dir` 的内容。
* *00:18* 指定 `test dir` 作为目标目录。注意横幅如何更新以向我们显示目标目录。增加了这一行。
  ```text
  "   Copy/Move Tgt: /tmp/vim/test dir/ (local)
  ```
* *00:20-00:25* 标记 `a-file.txt` 和 `another-file.txt`。为了指示它们被标记了，我用粗体显示了文件的名称。
* *00:25-00:27* 按 `mm` 移动文件，这些文件从当前窗口中消失。
* *00:29* 检查文件是否在 `test dir`中（它们在）。

这就是，复制和删除过程。运行外部命令和删除文件是一样的，只是我们不需要目标目录。

## Netrw 的局限性

### 移动文件时

这种情况发生在 Linux 上，也许 MacOS 也是如此。在前面的示例中，我们将 `a-file.txt` 移到了 `test dir`，这样做效果很好，但如果你尝试将
`a-file.txt` 移回父目录，则会收到以下错误：

```text
**error** (netrw) tried using g:netrw_localmovecmd<mv>; it doesn't work!
```

> 当你尝试复制时，则不会发生这种情况。

据我所知，当（缓冲区中的）当前目录与正在浏览的目录不匹配时，就会发生这种情况。要解决这个问题，可以将全局变量 `g：netrw_keepdir` 设置为零。

```vim
let g:netrw_keepdir = 0 
```

### 在标记的文件上执行操作时

当你尝试对标记的文件执行操作时，该操作仅适用于当前缓冲区中列出的文件。

假设有如下文件结构：

```text
vim
├── mini-plugins
│   ├── better-netrw.vim
│   ├── guess-indentation.vim
│   └── project-buffers.vim
├── test dir
│   ├── a-file.txt *
│   ├── another-file.txt *
│   └── text.txt
├── custom-commands.vim
└── init.vim *
```

带 `*` 的文件是被标记的文件。如果我们在 `vim` 目录中，并且尝试将文件移进 `mini plugins`，则只有 `init.vim` 被移进目标目录。

从理论上讲，这是一件好事，因为我们将始终看到正在操作的文件。

### 无法使用 `D` 删除非空目录

Netrw 不能使用 `D` 删除非空目录。当然，这个问题的答案是：使用外部命令。如果你注意了前面的部分，就会知道 `mx` 可以帮助我们做到这一点。

> 见 [asciinema](https://asciinema.org/a/YbscBomZSa752kXnEASUnaxlx)。

解决方案是：用 `mf` 标记目录，使用 `mx`，然后输入你需要的命令（示例中为 `rm -r`）。

但能让这件事变得更方便吗？可以，下一节将讨论这一点。

## 自定义

如果你决定给 Netrw 一个被使用的机会，你可能想要做一些调整，让它变得更好。

### 建议的配置

| 配置                                             | 说明                                                         |
|--------------------------------------------------|--------------------------------------------------------------|
| `let g:netrw_keepdir = 0`                        | 保持当前目录和浏览目录同步。这可帮助你避免移动文件时产生错误 |
| `let g:netrw_winsize = 30`                       | 在创建拆分时更改 Netrw 窗口的大小                            |
| `let g:netrw_banner = 0`                         | 隐藏横幅。要临时显示/隐藏它，可以在 Netrw 内使用 `I`         |
| `let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'` | 在加载时隐藏 `.` 开头的文件                                  |
| `let g:netrw_localcopydircmd = 'cp -r'`          | 更改复制命令，主要用于启用目录的递归复制                     |
| `hi! link netrwMarkFile Search`                  | 以与搜索匹配相同的方式突出显示已标记的文件[^hi]              |

[^hi]: 这是我能想到的最简单的高亮的方法。如果你在 Netrw 中开始搜索并标记了文件，这可能会引起一些混淆。如果你希望使用其他颜色，请 `:h highlight t`。

### 按键映射

现在 Netrw 看起来更好了，让我们让它更容易使用。

#### 更好地调用 Netrw

We begin by changing the way we call Netrw. We bind `:Lexplore` to a shortcut so we can toggle it whenever we want.

从调用 Netrw 的方式开始。将 `:Lexplore` 绑定到一个快捷方式，这样我们就可以随时切换它。

```vim
nnoremap <leader>dd :Lexplore %:p:h<CR>
nnoremap <Leader>da :Lexplore<CR> 
```

* `Leader dd`：在当前文件的目录中打开 Netrw
* `Leader da`：在当前工作目录中打开 Netrw

#### 导航

不幸的是，没有在 Netrw 中指定按键映射的直接方法。但我们仍然可以拥有它们，这需要几个步骤。

Netrw 是一个自定义了文件类型的插件，所以利用这一点，将按键映射放在一个函数中，并创建一个 `autocommand`，每当 Vim 打开一个 `netrw` 时就会调用它。

```vim
function! NetrwMapping()
endfunction

augroup netrw_mapping
  autocmd!
  autocmd filetype netrw call NetrwMapping()
augroup END 
```

在我们的配置中，现在要做的就是将按键映射放在 `NetrwMapping` 中，像这样：

```vim
function! NetrwMapping()
  nmap <buffer> H u
  nmap <buffer> h -^
  nmap <buffer> l <CR>
  nmap <buffer> . gh
  nmap <buffer> P <C-w>z
  nmap <buffer> L <CR>:Lexplore<CR>
  nmap <buffer> <Leader>dd :Lexplore<CR>
endfunction 
```

由于我们无法访问 Netrw 内部使用的函数（至少不是所有函数），所以使用 `nmap` 来创建按键映射。

例如，按 `h` 等同于按 `u`，而 `u` 将触发我们要执行的命令。这是上面设置的含义：

* `H`：“返回”历史
* `h`：到上级目录
* `l`：打开一个目录或文件
* `.`：切换 `.` 隐藏文件
* `P`：关闭预览窗口
* `L`：打开一个文件并关闭 Netrw
* `Leader dd`：关闭 Netrw

有了这些推荐的配置，Netrw 可以成为一个不错的文件资源管理器。但等等，我们还可以做得更多。

#### 标记

让我们找一个更好的方法来管理文件上的标记。我建议使用 `<Tab>`。

```vim
nmap <buffer> <TAB> mf
nmap <buffer> <S-TAB> mF
nmap <buffer> <Leader><TAB> mu 
```

* `Tab`：切换文件或目录上的标记
* `Shift Tab`：取消标记当前缓冲区中的所有文件
* `Leader Tab`：删除所有文件上的所有标记

### 文件管理

由于有相当多的命令与文件相关，我们将使用 `f` 键作为前缀将它们组合在一起。

```vim
nmap <buffer> ff %:w<CR>:buffer #<CR> 
nmap <buffer> fe R 
nmap <buffer> fc mc 
nmap <buffer> fC mtmc 
nmap <buffer> fx mm 
nmap <buffer> fX mtmm 
nmap <buffer> f; mx 
```

* `ff`：创建一个文件。但就像是真的创建了它。输入 `%` 后，使用 `:w<CR>` 保存空文件，使用 `:buffer #<CR>` 返回 Netrw。
* `fe`：重命名文件
* `fc`：复制标记的文件
* `fC`：使用此选项“跳过”一个步骤。将那些被标记的文件放如当前光标下的目录中，这将一步到位地进行指定目标目录和复制附件
* `fx`：移动标记的文件
* `fX`：与 `fC` 相同，但用于移动文件。
* `f;`：在标记的文件上运行外部命令。

如果你不介意使用 Netrw 的一些内部变量，我们仍然可以做额外的事情。

显示已标记文件的列表：

```vim
nmap <buffer> fl :echo join(netrw#Expose("netrwmarkfilelist"), "\n")<CR> 
```

显示目标目录，在我们想要避免使用横幅的时候：

```vim
nmap <buffer> fq :echo 'Target:' . netrw#Expose("netrwmftgt")<CR> 
```

可以将其与 `mt` 一起使用：

```
nmap <buffer> fd mtfq 
```

同样，只有当你真的想要避免显示横幅时，这才有用。

#### 书签

```vim
nmap <buffer> bb mb 
nmap <buffer> bd mB 
nmap <buffer> bl gb 
```

* `bb`：创建书签
* `bd`：删除最新的书签
* `bl`：跳到最新的书签

#### 递归删除文件

我们要做的最后一件事是“自动化”删除非空目录。为此，我们需要一个函数：

```vim
function! NetrwRemoveRecursive()
  if &filetype ==# 'netrw'
    cnoremap <buffer> <CR> rm -r<CR>
    normal mu
    normal mf
    
    try
      normal mx
    catch
      echo "Canceled"
    endtry

    cunmap <buffer> <CR>
  endif
endfunction
```

我们在这个函数中做的第一件事是检查是否在 Netrw 控制的缓冲区中。然后，准备 Remove 命令。进入命令模式，并创建一个快捷键映射 `<CR>`。接下来，使用
`normal mu` 清除所有的标记，因为不想不小心删除任何东西。然后用 `normal mf` 标记光标下的目录。有趣的是， `normal mx` 会问我们要执行什么命令，此时使用
`ctrl+c` 中止进程，或者按 `Enter`，这将触发命令 `rm -r`。最后，撤销在函数开始时创建的按键映射，因为永久拥有它将是可怕的。

我们该如何使用它呢？当然，在给 `NetrwMapping` 创建一个按键映射：

```vim
nmap <buffer> FF :call NetrwRemoveRecursive()<CR> 
```

你可以在[这里](https://gist.github.com/VonHeikemen/fa6f7c7f114bc36326cda2c964cb52c7)找到本文中的所有选项和函数。

## 总结

Netrw 可能不是 Vim 生态系统中最好的文件管理器，但只要稍加努力，我们就可以将其转变为一个直观的文件资源管理器。

即使你在工作流程中不采用 Netrw，知道如何使用它之后，在某些情况下也会很方便。如果手头没有你喜欢的 Vim 插件，你永远不知道什么时候会被困在远程服务器中。

更多内容见：[`:help netrw`](https://vimhelp.org/pi_netrw.txt.html)

