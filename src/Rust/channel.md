# channel

## channel 类型

| 方式                        | 相关函数        | 具体说明               |
|-----------------------------|-----------------|------------------------|
| stdin/stdout                | `stdioopen()`   |                        |
| stdin/stdou/stderr          | `jobstart()`    |                        |
| PTY                         | `termopen()`    | `:h terminal-emulator` |
| TCP/IP socket or named pipe | `sockconnect()` |                        |
| RPC[^RPC]                   | `serverstart()` | `:h rpc-connecting`    |

[^RPC]: RPC 让另一个进程连接 nvim 所监听的 socket，从而让 nvim 和另一进程相互发送远程调用和事件。
        而且 RPC 方式是隐式被信任的，进程端可以调用任何 nvim 的 api。

每一个 channel 在当前 nvim 会话期间，都被一个单独的整数 id 进行标识：
- `stdioopen()` 等创建 channel 的函数返回其 id
- `chansend()` 之类的函数消耗掉 id

channel 默认传递原始字节：nvim 端和另一进程端都只能读取字节。



## RPC

使用 RPC 的 API 客户端可以：
- 调用任何 API 函数
- 监听事件
- 从 nvim 获取远程调用


