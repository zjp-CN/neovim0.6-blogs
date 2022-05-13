# 基本概念 (GDB)

* [https://www.sourceware.org/gdb/documentation/](https://www.sourceware.org/gdb/documentation/)

## Stack Frames

[Stack Frames]: https://sourceware.org/gdb/current/onlinedocs/gdb/Frames.html#Frames

* [Stack Frames] 指分割调用栈 (call stack) 的连续区域
* 与一次函数调用的数据相关联：
    * 每调用一次函数，就会产生一个新的 frame[^fomit-frame-pointer]
    * 每当函数返回，就会消除这个函数的 frame
    * 关联的数据包括：函数参数、函数内的局部变量、函数执行的地址
* 根据地址来标识 frame：每个 frame 存储了许多字节，每个字节都有各自的地址
* 函数最初执行时只有一个 frame，所以 main 函数被称作 initial frame 或者 outermost frame
* GDB 标记 frame 的规则：
    * 用数字来描述每个 frame 所处的层级，这个数字被称作 frame number 或者 frame level
    * 0 表示最内层 frame：也就是该 frame 最后执行的函数调用
    * 1 表示调用 frame 0 的 frame
    * 以此类推：frame N+1 调用 frame N
    * GDB 的命令就是使用这些数字来指定 frame
    * 函数执行的顺序与这组数字所描述的相反：对于 frame 0-N，实际按照 N-0 的顺序进行函数调用

[^fomit-frame-pointer]: 并不是所有的函数调用都会产生 frame pointer，比如
[stackoverflow: Trying to understand gcc option -fomit-frame-pointer]

[stackoverflow: Trying to understand gcc option -fomit-frame-pointer]:
https://stackoverflow.com/questions/14666665/trying-to-understand-gcc-option-fomit-frame-pointer

## Backtrace

[backtrace]: https://sourceware.org/gdb/current/onlinedocs/gdb/Backtrace.html#Backtrace

* 回溯 ([backtrace]) 是程序如何到达某个位置的摘要：
    * 每行显示一个 frame
    * 显示多个 frames 时，从当前执行的 frame 开始（frame 0），然后是它的调用者（frame 1），然后在 stack 上堆叠起来
* 打印整个 stack 上的 frames 的命令是 `backtrace` （或者简写 `bt`）

### 基本命令

`bt [option]… [qualifier]… [count]`

| 参数          | 类型      | 说明                                                        |
|---------------|-----------|-------------------------------------------------------------|
| `-full`       | option    | 打印整个 stack 上的 frames，并且每个 frame 下显示其局部变量 |
| `-no-filters` | option    | 不运行 python frame filters                                 |
| `-hide`       | option    | 不打印 python filters 所省略的 frames                       |
| `full`        | qualifier | 同 `-full`                                                  |
| `no-filters`  | qualifier | 同 `-no-filters`                                            |
| `hide`        | qualifier | 同 `-hide`                                                  |
| `n`           | count     | 打印最内层的 n 个 frames 信息（即编号 0 到 n-1）            |
| `-n`          | count     | 打印最外层的 n 个 frames 信息（即倒数 n 个 frames）         |

例子：`bt full 3` 表示打印整个 stack 上的 0、1、2 frame，并且每个 frame 下显示其局部变量

```text
(gdb) bt -full full
#0  std::sys_common::backtrace::__rust_begin_short_backtrace<fn(), ()> (f=0x55555555cc80 <hi::main>) at /rust/rust/library/std/src/sys_common/backtrace.rs:125
        result = ()
#1  0x000055555555c6f1 in std::rt::lang_start::{closure#0}<()> () at /rust/rust/library/std/src/rt.rs:145
        main = 0x55555555cc80 <hi::main>
#2  0x00005555555606ae in std::panicking::try ()
No symbol table info available.
```

`#0` 表示当前程序停止在源代码的某处，比如这里停在了 backtrace.rs 文件的第 125 行。

如果程序是使用优化编译的，而且在调用后从未使用过传递给函数的参数，那么某些编译器将优化掉这些参数。

此类优化生成通过寄存器传递参数的代码，但不会将这些参数存储在 frame 中。GDB 无法在 frame 中显示这些参数。未保存在其 frame 中的参数可能显示为 `optimized out`。

如果需要显示此类优化输出参数的值，请从相关变量中推断出该值，或者在不进行优化的情况下重新编译。

### 相关设置

| 类型             | 命令                                                          | 说明                                       |
|------------------|---------------------------------------------------------------|--------------------------------------------|
| past-main        | `set backtrace past-main` 或者 `set backtrace past-main on`   | 遇到入口函数（比如 main）时不停止          |
| past-main        | `set backtrace past-main off` （这是默认行为）                | 遇到入口函数（比如 main）时停止            |
| past-main        | `show backtrace past-main`                                    | 显示遇到入口函数的行为（off/on）           |
| past-entry       | `set backtrace past-entry` 或者 `set backtrace past-entry on` | 遇到程序内部的入口函数时不停止             |
| past-entry       | `set backtrace past-entry off` （这是默认行为）               | 遇到程序内部的入口函数时停止               |
| past-entry       | `show backtrace past-entry`                                   | 显示遇到程序内部的入口函数的行为（off/on） |
| limit            | `set backtrace limit n`                                       | 最多展示 n 个 frames                       |
| limit            | `set backtrace limit 0` 或者 `set backtrace limit unlimited`  | 不限制展示 frames 的个数（这是默认行为）   |
| limit            | `show backtrace limit`                                        | 展示 frames 的个数限制                     |
| filename-display | `set filename-display` 或者 `set filename-display relative`   | 以相对路径展示源码文件名（这是默认行为）   |
| filename-display | `set filename-display absolute`                               | 以绝对路径展示源码文件名                   |
| filename-display | `set filename-display basename`                               | 以基本名称展示源码文件名                   |
| filename-display | `show filename-display`                                       | 当前展示源码文件名的方式                   |


视频：
* [Video Tutorial: Using LLDB in iOS Part 3: Backtraces, Threads, and Frames](https://www.raywenderlich.com/2426-video-tutorial-using-lldb-in-ios-part-3-backtraces-threads-and-frames)

## select

[select]: https://sourceware.org/gdb/current/onlinedocs/gdb/Selection.html#Selection

[选择][select]当前 stack 上的一个 frame，以下 `f` 都可以换成 `frame`。

### 基本命令

| 命令[^frame-selection-spec]        | 说明                                                                                         |
|------------------------------------|----------------------------------------------------------------------------------------------|
| `f n` 或者 `f level n`             | 选择 #n frame；不提供 n 时，则显示当前 frame                                                 |
| `f address stack-address`          | 选择某个地址的 frame                                                                         |
| `f function function-name`         | 选择某函数名的 frame，多条情况时选择最内层（数字最小）的 frame                               |
| `f view stack-address [ pc-addr ]` | 查看当前 GDB backtrace 之外的 frame                                                          |
| `up n`                             | 如果当前处在 #m，则选择第 #m+n；不提供 n 时，则选择第 #m+1；m+n 超过最大级别时，选择最大级别 |
| `down n`                           | 如果当前处在 #m，则选择第 #m-n；不提供 n 时，则选择第 #m-1；m-n 低于最低级别时，选择 #0      |

[^frame-selection-spec]: 前四行形式为 `f [ frame-selection-spec ]`

使用这些选择命令之后，会打印被选中的 frame 的两行信息。比如：

```text
#0  hi::main () at src/main.rs:2
2           let a = vec![12];
```

当你不需要自动打印信息时，可以使用 `select-frame`、`up-silentl`、`down-silently` 来代替 `f`、`up`、`down`。

```text
#0   -> innermost
...
#m-n -> down n | f m-n
...
#m-1 -> down   | f m-1

#m   -> f

#m+1 -> up
...
#m+n -> up n   | f m+n
...
#max -> outermost
```

### 查看信息

[info]: https://sourceware.org/gdb/current/onlinedocs/gdb/Frame-Info.html#Frame-Info

选择 frame 之后，你可以使用以下命令查看它的[信息][info]：

| 命令                                         | 说明                                                                                                                          |
|----------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| `f`                                          | 显示当前 frame 的两行信息                                                                                                     |
| `info f`                                     | 显示当前 frame 的具体信息                                                                                                     |
| `info f [ frame-selection-spec ]`            | 显示指定 frame 的具体信息（但不改变被选择的 frame）                                                                           |
| `list`                                       | 打印以执行点为中心的 10 行源码                                                                                                |
| `info args [-q]`                             | 打印所选 frame 的参数，每一个都在单独的行上；可选的 `-q` 代表禁止打印头信息                                                   |
| `info args [-q] [-t type_regexp] [regexp]`   | 如果提供 regexp，则只打印名称与正则表达式 regexp 相匹配的参数；也可以提供类型正则表达式；当两者都提供时，必须都满足才匹配显示 |
| `info locals [-q]`                           | 与 args 的情况类似，但打印所选 frame 的局部变量                                                                               |
| `info locals [-q] [-t type_regexp] [regexp]` | 与 args 的情况类似，但打印所选 frame 的局部变量                                                                               |

The command info locals -q -t type_regexp can usefully be combined with the commands frame apply and thread apply. For example, your program might use Resource Acquisition Is Initialization types (RAII) such as lock_something_t: each local variable of type lock_something_t automatically places a lock that is destroyed when the variable goes out of scope. You can then list all acquired locks in your program by doing

thread apply all -s frame apply all -s info locals -q -t lock_something_t
or the equivalent shorter form

tfaas i lo -q -t lock_something_t


```text
(gdb) f
#0  alloc::alloc::exchange_malloc (size=4, align=4) at /rust/rust/library/alloc/src/alloc.rs:320
320         match Global.allocate(layout) {

(gdb) list
315     #[cfg(all(not(no_global_oom_handling), not(test)))]
316     #[lang = "exchange_malloc"]
317     #[inline]
318     unsafe fn exchange_malloc(size: usize, align: usize) -> *mut u8 {
319         let layout = unsafe { Layout::from_size_align_unchecked(size, align) };
320         match Global.allocate(layout) {
321             Ok(ptr) => ptr.as_mut_ptr(),
322             Err(_) => handle_alloc_error(layout),
323         }
324     }

(gdb) info args
size = 4
align = 4

(gdb) info locals
layout = core::alloc::layout::Layout {size: 4, align: core::mem::valid_align::ValidAlign (core::mem::valid_align::ValidAlignEnum64::_Align1Shl2)}

(gdb) info args size
size = 4

(gdb) info locals -t Layout
layout = core::alloc::layout::Layout {size: 4, align: core::mem::valid_align::ValidAlign (core::mem::valid_align::ValidAlignEnum64::_Align1Shl2)}

(gdb) info args -t usize size
size = 4

(gdb) info f
Stack level 0, frame at 0x7fffffffe230:
 rip = 0x55555555d091 in alloc::alloc::exchange_malloc
    (/rust/rust/library/alloc/src/alloc.rs:320); saved rip = 0x55555555cc91
 called by frame at 0x7fffffffe280
 source language rust.
 Arglist at 0x7fffffffe1c8, args: size=4, align=4
 Locals at 0x7fffffffe1c8, Previous frame's sp is 0x7fffffffe230
 Saved registers:
  rip at 0x7fffffffe228
```

`info f` 包括以下内容：
* 当前 frame 的地址
* 下一个 frame 的地址（被当前 frame 调用的 frame, down）
* 上一个 frame 的地址（调用当前 frame 的 frame, up）
* 编写此 frame 的源代码的语言
* frame 参数的地址
* frame 局部变量的地址
* 调用当前 frame 时的执行地址
* frame 中保存的寄存器

## 基本命令

1. 关闭 gdb：`quit` 或者 `Ctrl-d`

2. 日志：
    * `help set logging` 查看可设置的内容及说明
    * `set logging on` 开启日志，将之后命令和内容输出到当前目录下的 gdb.txt 文件（默认不开启日志）

3. 运行 shell 命令：
    * 执行单条：`shell command-string` 或者 `!command-string`
    * 执行多条：
        * 默认以 `|` 分隔：`pipe [command] | shell_command` 或者 `| [command] | shell_command`
        * 自定义分隔符：`pipe -d delim command delim shell_command` 或者 `| -d delim command delim shell_command`
    ```text
    (gdb) pipe p var|wc
      7      19      80
    (gdb) |p var|wc -l
    7
    (gdb) p /x var
    $4 = {
      black = 0x90,
      red = 0xe9,
      green = 0x179,
      blue = 0x262,
      white = 0x3db
    }
    (gdb) ||grep red
      red => 0xe9,
    (gdb) | -d ! echo this contains a | char\n ! sed -e 's/|/PIPE/'
    this contains a PIPE char
    (gdb) | -d xxx echo this contains a | char!\n xxx sed -e 's/|/PIPE/'
    this contains a PIPE char!
    ```

4. 重复上一个命令：回车键或者 `Ctrl-o`。
    * 有些命令不会被重复，比如 `run`
    * 对于自定义命令，使用 `dont-repeat` 可以让该命令不被重复
    * 对于 `list` 和 `x` 命令，重复时会构造新的参数来方便显示源代码或内存
    * `#` 开头的内容直到这行结束，表示注释，而不是重复
    * 按回车键进行重复可以搭配[屏幕尺寸][Screen-Size]的相关设置来更方便显示长内容

5. 修改设置：
    * 全局设置：`set`
    * 局部设置：`with setting [value] [-- command]` 或者 `w setting [value] [-- command]`
    ```text
    (GDB) set print elements 10
    (GDB) print some_array
    $1 = {0, 10, 20, 30, 40, 50, 60, 70, 80, 90...}

    # 有些命令支持接受参数来覆盖全局设置
    (GDB) print -elements 10 -- some_array
    $1 = {0, 10, 20, 30, 40, 50, 60, 70, 80, 90...}

    # with 可用于临时覆盖全局设置
    (GDB) with print array on -- print some_array
    # 等价于
    (GDB) set print array on
    (GDB) print some_array
    (GDB) set print array off
    # 可以嵌套
    (GDB) with language ada -- with print elements 10
    ```

5. 补全：使用 Tab 键可以补全或者提示可输入的内容。此外，如果命令是明确的，其名称可以被截断。
    * 比如 `info bre TAB`、`info bre`、`inf b` 与 `info breakpoints` 等价
    * 比如 `print -object on -pretty off -element unlimited -- *myptr` 与 `p -o -p 0 -e u -- *myptr` 等价
    * 补全设置：`set max-completions limit`、`set max-completions unlimited`、`show max-completions`

6. 帮助：
    * `help` 或者 `h`：查看命令的文档介绍
    * `apropos [-v] regexp`：从命令名称和文档介绍中，寻找符合正则内容的命令
    * `complete args`：从开头补全中寻找命令
    * `info` 或者 `i`：查看程序的状态，详情见 `help info`
    * `show` 或者 `info set`：查看 GDB 的状态（比如 `show configuration` 查看配置信息），详情见 `help show`

[Screen-Size]: https://sourceware.org/gdb/current/onlinedocs/gdb/Screen-Size.html#Screen-Size

## Checkpoint

[checkpoint]: https://sourceware.org/gdb/current/onlinedocs/gdb/Checkpoint_002fRestart.html#Checkpoint_002fRestart

checkpoint
保存被调试程序当前执行状态的快照。该checkpoint命令不带参数，但每个检查点都分配了一个小的整数 id，类似于断点 id。

```text
info checkpoints
restart checkpoint-id
delete checkpoint checkpoint-id
```

## 显示程序状态

| 命令                                 | 说明                               |
|--------------------------------------|------------------------------------|
| `info program`                       | 是否在运行、运行的线程、为什么中止 |
| `info inferiors`                     | 查看进程、程序的绝对路径           |
| `info threads`                       | 查看线程、stack 信息               |
| `thread apply all bt`                | 查看所有线程的所有 stack           |
| `thread apply thread1 thread2... bt` | 查看指定线程所有 stack             |


```text
(gdb) info program
        Using the running image of child Thread 0x7ffff7d88bc0 (LWP 477478).
Program stopped at 0x55555555d347.
It stopped at breakpoint 1.
Type "info stack" or "info registers" for more information.

(gdb) info inferiors
  Num  Description       Connection           Executable
* 1    process 477478    2 (native)           /rust/tmp/hi/target/debug/hi

(gdb) info threads
  Id   Target Id                               Frame
* 1    Thread 0x7ffff7d88bc0 (LWP 477478) "hi" hi::main () at src/main.rs:2

(gdb) thread apply all bt
Thread 1 (Thread 0x7ffff7d88bc0 (LWP 477478) "hi"):
#0  hi::main () at src/main.rs:2

(gdb) thread apply 1 bt
Thread 1 (Thread 0x7ffff7d88bc0 (LWP 477478) "hi"):
#0  hi::main () at src/main.rs:2
```

## Breakpoints

### 设置断点

| 命令（`break` 可简写为 `b`）                | 说明                                                                                                                                                                                                      |
|---------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `break location`                            | 设置断点：location 可以是函数名、行号或指令地址。                                                                                                                                                         |
| `break`                                     | 在所处 stack 的待执行的下一条指令设置断点，即在命令 `f` 处设置断点                                                                                                                                        |
| `break location [-force-condition] if cond` | 给定某个位置的表达式，当运行到此断点且满足这个表达式时，中止；如果表达式在该断点处所有位置不合法（比如不存在某个符号），则设置断点失败，但提供 `-force-condition` 参数可强制设置                          |
| `tbreak args`                               | 与 `break` 功能一样，但设置的断点是一次性的，当程序第一次在该断点中止之后便被自动删除                                                                                                                     |
| `hbreak args` 和 `thbreak args`             | 类似于 `break` 和 `tbreak`，但专门针对硬件相关的测试提供                                                                                                                                                  |
| `rbreak regex` 和 `rbreak file:regex`       | 对所有符合正则表达式的函数设置断点，比如 `rbreak .` 设置把该程序内的所有函数设置断点。注意：`foo*` 表示 `fo` 后跟 0 或更多 o；且会隐式对正则内容的前后添加 `.*`，如果指定以 `foo` 开头的函数，使用 `^foo` |
| `info breakpoints [list…]` 或者 `i b ...`   | 查看所有已设置但未删除的 breakpoints, watchpoints, catchpoints                                                                                                                                            |
| `set breakpoint pending auto/on/off`        | 当 GDB 找不到断点位置时，询问/允许/禁止创建待办断点                                                                                                                                                       |
| `show breakpoint pending`                   | 显示用于创建待办断点的当前行为设置                                                                                                                                                                        |

### 删除和禁用

| 命令                                 | 说明                                                                                                    |
|--------------------------------------|---------------------------------------------------------------------------------------------------------|
| `delete`                             | GDB 会询问你删除所有断点；可缩写成 `d`、`del`                                                           |
| `delete [breakpoints] [list…]`       | 删除某些 breakpoints, watchpoints, catchpoints；比如 `d 1-4` 删除序号为 1-4 的断点等类型                |
| `clear`                              | 删除当前 frame 待执行的下一个断点                                                                       |
| `clear location`                     | [location] 例子：`clear function`、`clear filename:function`、`clear linenum`、`clear filename:linenum` |
| `disable`                            | 关闭所有断点，这不会对程序造成影响，而且断点依然存在                                                    |
| `disable [breakpoints] [list…]`      | 关闭某些断点                                                                                            |
| `enable`                             | 开启所有断点                                                                                            |
| `enable [breakpoints] [list…]`       | 开启某些断点                                                                                            |
| `enable [breakpoints] once list…`    | 先开启某些断点，在中止程序之后，关闭这些断点                                                            |
| `enable [breakpoints] count n list…` | 先开启某些断点，在中止程序 n 次之后（以倒数形式计数），关闭这些断点                                     |
| `enable [breakpoints] delete list…`  | 先开启某些断点，在中止程序之后，删除这些断点；与 `tbreak` 命令功能一致                                  |

[location]: https://sourceware.org/gdb/current/onlinedocs/gdb/Specify-Location.html#Specify-Location

### 其他设置

| 命令                          | 说明                                                                                                                                        |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| `condition bnum expression`   | 对已设置的断点附加中止条件                                                                                                                  |
| `break ... commands ... end`  | 对某断点中止之后设置运行额外的命令                                                                                                          |
| `save breakpoints [filename]` | 保存已设置的断点；使用 `source filename` 命令读取和加载断点；及局部变量的表达式的观察点可能无法重新创建，因为可能无法访问观察点有效的上下文 |


### 案例

```rust
fn main() {
    let a = vec![12, 16];
    let b = f(a[0]);
    dbg!(b);
}

fn f(a: i32) -> i32 { a + 1 }
```

```text
(gdb) b main
Breakpoint 1 at 0x9347: main. (2 locations)
(gdb) b f
Breakpoint 2 at 0x9605: file src/main.rs, line 7.
(gdb) b main.rs:4 if b > 0
Breakpoint 3 at 0x93f8: file src/main.rs, line 4.
(gdb) i b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   <MULTIPLE>
1.1                         y   0x0000000000009347 in hi::main at src/main.rs:2
1.2                         y   0x0000000000009640 <main>
2       breakpoint     keep y   0x0000000000009605 in hi::f at src/main.rs:7
3       breakpoint     keep y   0x00000000000093f8 in hi::main at src/main.rs:4
        stop only if b > 0
(gdb) r
Starting program: /rust/tmp/hi/target/debug/hi
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".

Breakpoint 1, 0x000055555555d640 in main ()
(gdb) c
Continuing.

Breakpoint 1, hi::main () at src/main.rs:2
2           let a = vec![12, 16];
(gdb) c
Continuing.

Breakpoint 2, hi::f (a=12) at src/main.rs:7
7       fn f(a: i32) -> i32 { a + 1 }
(gdb) c
Continuing.

Breakpoint 3, hi::main () at src/main.rs:4
4           dbg!(b);
(gdb) c
Continuing.
[src/main.rs:4] b = 13
[Inferior 1 (process 459778) exited normally]
```

这里由 `b main` 导致的多行断点只能删除整个断点 `del 1`，无法删除一行，但可禁用，比如 `disable 1.2`。

当然，也可以禁用整个断点 `disable 1`，或者禁用多个断点 `disable 1.1 1.2`。

## Watchpoints

监测点是一种特殊的断点。

### 类型

| 命令          | 说明                                           |
|---------------|------------------------------------------------|
| `watch expr`  | 当表达式的值被程序 **修改** 的时候终止         |
| `rwatch expr` | 当表达式的值被程序 **读取** 的时候终止         |
| `awatch expr` | 当表达式的值被程序 **读取或者修改** 的时候终止 |

1. 这三个命令的支持的完整参数为 `watch [-l|-location] expr [thread thread-id] [mask maskvalue] [task task-id]`
2. `info watchpoints [list…]` 或者 `i b` 命令可查看监测点；使用 `del` 或 `disable` 删除或禁用
3. 无法监听地址，因为地址从不被改变，如果要监听某个地址的值，需要对地址解引用
4. GDB 尽可能设置硬件所支持的监测点，因为这样执行起来很快，而且 GDB 能准确地报告修改值的指令
5. 如果使用软件监测点，那么执行起来更慢，而且在修改值的下一个语句才会报告监测点的情况
6. 只能基于作用域内的变量的表达式设置监测点，而且当执行离开定义这些变量的块时，GDB 会自动删除这些监视点
7. 更多细节参考文档：[watchpoints](https://sourceware.org/gdb/current/onlinedocs/gdb/Set-Watchpoints.html#Set-Watchpoints)

### 案例

```rust
#fn main() {
#    let a = vec![12, 16];
#    let b = f(a[0]);
#    let c = b;
#    dbg!(b);
#}
#
fn f(mut a: i32) -> i32 {
    println!("{a}");
    a += 1;
    a + 1
}
```

1. 监视变量

运行至某个函数内：

```text
(gdb) b f
Breakpoint 1 at 0xa838: file src/main.rs, line 9.
(gdb) r
Starting program: /rust/tmp/hi/target/debug/hi
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".

Breakpoint 1, hi::f (a=12) at src/main.rs:9
9           println!("{a}");
```

方式一：使用 `watch`：

```text
(gdb) watch a
Hardware watchpoint 2: a
(gdb) c
Continuing.
12

Hardware watchpoint 2: a

Old value = 12
New value = 13
hi::f (a=13) at src/main.rs:11
11          a + 1
(gdb)
Continuing.

Watchpoint 2 deleted because the program has left the block in
which its expression is valid.
0x000055555555e601 in hi::main () at src/main.rs:3
3           let b = f(a[0]);
```

方式二：使用 `rwatch`

```text
(gdb) rwatch a
Hardware read watchpoint 3: a
(gdb) c
Continuing.

Hardware read watchpoint 3: a

Value = 12
0x0000555555590dbb in core::fmt::num::imp::<impl core::fmt::Display for i32>::fmt ()
(gdb)
Continuing.
12

Hardware read watchpoint 3: a

Value = 12
0x000055555555e890 in hi::f (a=12) at src/main.rs:10
10          a += 1;
(gdb)
Continuing.

Hardware read watchpoint 3: a

Value = 13
0x000055555555e8a9 in hi::f (a=13) at src/main.rs:11
11          a + 1
(gdb)
Continuing.

Watchpoint 3 deleted because the program has left the block in
which its expression is valid.
0x000055555555e601 in hi::main () at src/main.rs:3
3           let b = f(a[0]);
```

方式三：使用 `awatch`

```text
(gdb) awatch a
Hardware access (read/write) watchpoint 4: a
(gdb) c
Continuing.

Hardware access (read/write) watchpoint 4: a

Value = 12
0x0000555555590dbb in core::fmt::num::imp::<impl core::fmt::Display for i32>::fmt ()
(gdb)
Continuing.
12

Hardware access (read/write) watchpoint 4: a

Value = 12
0x000055555555e890 in hi::f (a=12) at src/main.rs:10
10          a += 1;
(gdb)
Continuing.

Hardware access (read/write) watchpoint 4: a

Old value = 12
New value = 13
hi::f (a=13) at src/main.rs:11
11          a + 1
(gdb)
Continuing.

Hardware access (read/write) watchpoint 4: a

Value = 13
0x000055555555e8a9 in hi::f (a=13) at src/main.rs:11
11          a + 1
(gdb)
Continuing.

Watchpoint 4 deleted because the program has left the block in
which its expression is valid.
0x000055555555e601 in hi::main () at src/main.rs:3
3           let b = f(a[0]);
```

2. 监视 `Vec`

```text
(gdb) start
Temporary breakpoint 1 at 0xa567: file src/main.rs, line 2.
Starting program: /rust/tmp/hi/target/debug/hi
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".

Temporary breakpoint 1, hi::main () at src/main.rs:2
2           let a = vec![12, 16];
(gdb) n
3           let b = f(a[0]);
(gdb) rwatch *a.buf.ptr.pointer.pointer@2
Hardware read watchpoint 2: *a.buf.ptr.pointer.pointer@2
(gdb) n

Hardware read watchpoint 2: *a.buf.ptr.pointer.pointer@2

Value = [12, 16]

Hardware read watchpoint 2: *a.buf.ptr.pointer.pointer@2

Value = [12, 16]
0x000055555555decc in alloc::raw_vec::RawVec<i32, alloc::alloc::Global>::ptr<i32, alloc::alloc::Global> (self=0x7fffffffe188) at /rust/rust/library/alloc/src/raw_vec.rs:225
225             self.ptr.as_ptr()

...

(gdb)
No frame is currently executing in specified block
Command aborted.
(gdb) del 2
```

3. 监视自定义表达式：

```text
(gdb) watch a-12>0
Hardware watchpoint 3: a-12>0
(gdb) n
12
10          a += 1;
(gdb)

Hardware watchpoint 3: a-12>0

Old value = false
New value = true
hi::f (a=13) at src/main.rs:11
11          a + 1
```

## Reverse

> src: [ReverseDebug](https://sourceware.org/gdb/wiki/ReverseDebug) 
> | [reversible](https://www.sourceware.org/gdb/news/reversible.html)

步骤：
1. `record` 或者 `target record` 开启记录/回放功能：
    * 必须在 `run` 之后使用
    * 可以在任意一处 frame 开启记录
    * 只能倒放开启之后所记录的 frame
    * `record stop`：结束记录，清除已执行的日志，但不终止子进程，所以可以继续正常调试
    * `record delete`：清除已执行的日志，并开始新的执行日志
    * `set record insn-number-max`：设置记录执行指令的最大个数，默认为 20W 条，0 时表示无限个数
    * `set record stop-at-limit`：当达到最大个数时，若为 on（这是默认行为），则停止并询问；若为 off，则清除旧记录来腾放新记录
    * `info record`：显示线程记录的统计信息
2. 相关命令

| 命令                                      | 缩写  | 说明                                                  |
|-------------------------------------------|-------|-------------------------------------------------------|
| `reverse-continue`                        | `rc`  | 倒回到一个终止事件（如断点、观察点、异常）            |
| `reverse-next`                            | `rn`  | 倒回到上一次执行                                      |
| `reverse-nexti`                           | `rni` | 倒回一个机器指令，如果这个指令是函数返回，则反向执行  |
| `reverse-step`                            | `rs`  | 倒回到当前执行源码的开始                              |
| `reverse-stepi`                           |       | 准确地倒回一个机器指令                                |
| `reverse-finish`                          |       | 倒回到当前 frame 执行之前                             |
| `set exec-direction [forward \| reverse]` |       | 设置接下来的 (continue/step) 等操作是按照向前还是反向 |

3. 断点和观察点都依然有效，只不过以反向顺序进行
4. 反向调试[只支持部分平台](https://www.sourceware.org/gdb/news/reversible.html)

