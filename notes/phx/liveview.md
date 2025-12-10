# Phx liveview

LiveViews are processes that receive events, update their state, and render updates to a page as diffs.

- https://hexdocs.pm/phoenix/1.8.0/live_view.html
- https://hexdocs.pm/phoenix/1.8.0/Mix.Tasks.Phx.Gen.Live.html
- https://hexdocs.pm/phoenix_live_view/welcome.html#what-is-a-liveview


## Live stream and search

- https://hexshift.medium.com/how-to-build-a-live-search-feature-with-phoenix-liveview-55ea492c304a
- https://hexdocs.pm/phoenix_live_view/1.1.0-rc.4/Phoenix.LiveView.html#stream/4

### Pagination

- https://hexdocs.pm/phoenix_live_view/1.1.0-rc.4/bindings.html#scroll-events-and-infinite-pagination

## Debug

- [live-debuger](https://github.com/software-mansion/live-debugger?tab=readme-ov-file#getting-started)

Best Practices
Keep your LiveView modules focused
Use components for reusable UI elements
Leverage assign_async for loading data
Handle disconnections gracefully
Test your LiveViews thoroughly

## 发送的典型event message

```
 %Phoenix.Socket.Message{
   topic: "lv:phx-GHvKNi_UoKDddT5C",
   event: "event",
   payload: %{"event" => "inc", "type" => "click", "value" => %{"value" => ""}},
   ref: "13",
   join_ref: "4"
 }
```

- topic 是什么时候生成的？？？ 由客户端生成和发送的吗？
- live_socket_id 什么机制
- 整个工作机制是什么？

## 代码原理

- 初始get的页面在一个process 调用 mount后渲染页面，返给前端（这是那个进程，conn process？）
  - js worker 触发建立ws连接
- 服务端生成liveview进程，二次调用mount，生成socket state
  - 后续根据state变化将页面diffs主动推送给前端

- Phoenix.LiveView.Socket use Phoenix.Socket
- Phoenix.LiveView.Channel 对页面状态进行管理
  - 没有基于Phoenix.Channel那一套（只要有child_spec/1就能满足于Phoenix.Socket相关Transport交互的需要）
  - channel进程本质是个定制的GenServer
  - 由Phoenix.Socket 转发消息给channel进程，进行具体的消息交互、页面状态管理
    - 问题-消息管理有点零碎！不易于快速理解
  - 页面在channel中管理
  - %Phoenix.LiveView.Socket{root_pid: #PID<0.35237.0>,}
    - root_pid是channel的pid
    - Liveview本质是个channel？
    - 同live页面在不同tab中不共享状态？
  - 来自socket的消息还是由 Phoenix.Channel.Server.join生成channel 进程后 进行进程间消息传递
  - Phoenix.LiveView.Channel有大量的handle_info 方法处理各种消息

    ```
    defmodule Phoenix.Socket do
      defp handle_in(
          nil,
          %{event: "phx_join", topic: topic, ref: ref, join_ref: join_ref} = message,
          state,
          socket
        ) do
      case socket.handler.__channel__(topic) do
        {channel, opts} ->
          case Phoenix.Channel.Server.join(socket, channel, message, opts) do
            {:ok, reply, pid} ->
              reply = %Reply{
                join_ref: join_ref,
                ref: ref,
                topic: topic,
                status: :ok,
                payload: reply
              }

              state = put_channel(state, pid, topic, join_ref)
              {:reply, :ok, encode_reply(socket, reply), {state, socket}}
              
      defp handle_in({pid, _ref, _status}, message, state, socket) do
        send(pid, message)
        {:ok, {state, socket}}
      end
    ```

    ```
    defmodule Phoenix.Channel.Server do
      @spec join(Socket.t(), module, Message.t(), keyword) :: {:ok, term, pid} | {:error, term}
      def join(socket, channel, message, opts) do
        %{topic: topic, payload: payload, ref: ref, join_ref: join_ref} = message

        starter = opts[:starter] || &PoolSupervisor.start_child/3
        assigns = Map.merge(socket.assigns, Keyword.get(opts, :assigns, %{}))
        socket = %{socket | topic: topic, channel: channel, join_ref: join_ref || ref, assigns: assigns}
        ref = make_ref()
        from = {self(), ref}
        child_spec = channel.child_spec({socket.endpoint, from})

        case starter.(socket, from, child_spec) do
          {:ok, pid} ->
            send(pid, {Phoenix.Channel, payload, from, socket})
            mon_ref = Process.monitor(pid)
    ```

    ```
    defmodule Phoenix.LiveView.Channel
      @impl true
      def handle_info({Phoenix.Channel, auth_payload, from, phx_socket}, ref) do
        Process.demonitor(ref)
        mount(auth_payload, from, phx_socket)
      rescue
        # Normalize exceptions for better client debugging
        e -> reraise(e, __STACKTRACE__)
      end
    ```

- https://hexdocs.pm/phoenix/Phoenix.Socket.Transport.html#module-custom-transports