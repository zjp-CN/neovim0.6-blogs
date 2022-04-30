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

选择 frame 之后，你可以使用以下命令查看它的信息：

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

