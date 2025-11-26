# Socket & Channel

- https://hexdocs.pm/phoenix/channels.html
- https://hexdocs.pm/phoenix/1.8.1/Phoenix.ChannelTest.html

```
$ mix phx.gen.socket User      
* creating lib/slink_web/channels/chat_socket.ex
* creating assets/js/chat_socket.js

Add the socket handler to your `lib/slink_web/endpoint.ex`, for example:

    socket "/socket", SlinkWeb.ChatSocket,
      websocket: true,
      longpoll: false

For the front-end integration, you need to import the `chat_socket.js`
in your `assets/js/app.js` file:

    import "./chat_socket.js"

$ mix phx.gen.channel Room
* creating lib/slink_web/channels/room_channel.ex
* creating test/slink_web/channels/room_channel_test.exs
* creating test/support/channel_case.ex

Add the channel to your `lib/slink_web/channels/chat_socket.ex` handler, for example:

    channel "room:lobby", SlinkWeb.RoomChannel
```

## Phoenix.Socket

- Phoenix.Socket.Transport behaviour is superset of WebSock behaviour
  - 以支持多transport（如websocket和longpoll）和进程管理等
  - deps/phoenix/lib/phoenix/transports/websocket.ex
- Phoenix.Socket impl Phoenix.Socket.Transport behaviour，并与channel机制配合实现多播
- channel 是phoenix.socke上的多client广播机制，基于pubsub，抽象了transport（如websocket、longpoll等）

- 什么时候调用Phoenix.Socket的connect/3 callback?
  - 总结一句话： 用户connect时触发的 connection upgrade（websocket connection构建），进入websocket模式前的连接阶段,前后connection是同一个pid
  - deps/phoenix/lib/phoenix/transports/websocket.ex plug
  - 在use Phoenix.Socket 时 以实现了 Phoenix.Socket.Transport behaviours(包括connect)， 这个Transport behaviour是WebSock的超集（新增了connect等）
  - upgrade到websocket connection之前调用（由用户连接socket时触发）
    - 注意 ChatSocket中有两个connect版本， connect/1是use Phoenix.Socket时带过来的，connect/3才是实现的 Phoenix.Socket 的 connect callback
    - 会先调取 Phoenix.Socket.connect/1, -> Phoenix.Socket.__connect__/3 -> Phoenix.Socket.user_connet/6 -> callback的 connect/3 
    或 connect/2，从而完成从普通http connection到websocket connection的升级（进而可使用Bandit.Websocket.Handler handle_in接受新的消息）
      - Phoenix.Socket.user_connet/6 中构建了 socket = %Phoenix.Socket{} 实例
    - ChatSocket 就是 Bandit.Websocket.Handler中的WebSock handler
  - connect(params, socket, connect_info) callback中
    - params 来源于connection upgrade过程中从普通http connection中传过来的参数
    - connnect_info 是 connection upgrade中 基于conn和 endpoint中socket配置（connect_info: [session: []]）生成的，包括session信息
      - https://hexdocs.pm/phoenix/1.8.1/Phoenix.Endpoint.html#socket/3-connect-info
      - https://hexdocs.pm/phoenix/1.8.1/Phoenix.Endpoint.html#socket/3-common-configuration
    ```
      connect_info =
          Transport.connect_info(conn, endpoint, keys, Keyword.take(opts, @connect_info_opts))
    ```

    ```
        config = %{
          endpoint: endpoint,
          transport: :websocket,
          options: opts,
          params: params,
          connect_info: connect_info
        }

        case handler.connect(config) do
          {:ok, arg} ->
            try do
              conn
              |> WebSockAdapter.upgrade(handler, arg, opts)
              |> halt()
            rescue
              e in WebSockAdapter.UpgradeError -> send_resp(conn, 400, e.message)
            end
    ```

    
- 什么时候调用的Phoenix.Socket的id/1 callback?
  - deps/phoenix/lib/phoenix/socket.ex 
  - connect后构建完 socket
  - user_connect/6 -> handler.id(socket)，  handler的例子 是 ChatSocket
  - 有的话设置socket中的id字段，常用于标识一个user相关的所有sockets，方便一起disconnect
  ```
   defp user_connect(handler, endpoint, transport, serializer, params, connect_info) do
    # The information in the Phoenix.Socket goes to userland and channels.
    socket = %Socket{...   }

    # The information in the state is kept only inside the socket process.
    state = %{
      channels: %{},
      channels_inverse: %{}
    }

    connect_result =
      if function_exported?(handler, :connect, 3) do
        handler.connect(params, socket, connect_info)
      else
        handler.connect(params, socket)
      end

    case connect_result do
      {:ok, %Socket{} = socket} ->
        case handler.id(socket) do
          nil ->
            {:ok, {state, socket}}

          id when is_binary(id) ->
            # update the process label
            set_label(socket)
            {:ok, {state, %{socket | id: id}}}

          invalid ->
            Logger.warning(
              "#{inspect(handler)}.id/1 returned invalid identifier " <>
                "#{inspect(invalid)}. Expected nil or a string."
            )

            :error
        end

  ```

- 什么时候调用RoomChannel（use Phoenix.Channel）的join callback？
  - 总结一句话：用户进入channel进程后执行的首个回调！
  - 对应的transport socket handler（如ChatSocket）接受到phx_join event消息时会触发join
    ChatSocket.handle_in --> Phoenix.Socket.__in__/2 def __in__({payload, opts}, {state, socket}) --> Phoenix.Socket.handle_in/4
  - 这里的socket是ChatSocket，channel是RoomChannel
  - Phoenix.Channel.Server.join 中会触发 Phoenix.Socket.PoolSupervisor.start_child 构建 channel process，Phoenix.Socket.PoolSupervisor是个dynamic supervisor，由 应用的Endpoint supvisor tree负责启动，一般是对应core数量的多个
    - 可见channel的实例是构建在socket transport上的，并从上游socket中获取消息并做出反馈
    - Phoenix.Socket.PoolSupervisor启动 channel进程后会 send(pid, {Phoenix.Channel, payload, from, socket})
    - Phoenix.Channel.Server.handle_info 接受并处理 socket状态更新 相关 channel_pid，并做出可能的init reply
    - 并调用 channel_join/4 -> channel.join/3 callback; 可见是是在 新产生的 channel process中触发的join/3回调
    - 如果join :ok后 在init_join/3中 触发 PubSub.subscribe(pubsub_server, topic, metadata: fastlane)
      ```
      def handle_info({Phoenix.Channel, auth_payload, {pid, _} = from, socket}, ref) do
        socket = %{
          socket
          | channel_pid: self(),
            private: Map.merge(channel.__socket__(:private), private)
        }

        ...
        {reply, state} = channel_join(channel, topic, auth_payload, socket)
        ...
        GenServer.reply(from, reply)
        state
      end

      defp channel_join(channel, topic, auth_payload, socket) do
        case channel.join(topic, auth_payload, socket) do
          {:ok, socket} ->
            {{:ok, %{}}, init_join(socket, channel, topic)}

          {:ok, reply, socket} ->
            {{:ok, reply}, init_join(socket, channel, topic)}

          {:error, reply} ->
            {{:error, reply}, {:stop, :shutdown, socket}}
      end
      defp init_join(socket, channel, topic) do
        %{transport_pid: transport_pid, serializer: serializer, pubsub_server: pubsub_server} = socket

        unless pubsub_server do
          raise """
          The :pubsub_server was not configured for endpoint #{inspect(socket.endpoint)}.
          """
        end

        Process.monitor(transport_pid)
        fastlane = {:fastlane, transport_pid, serializer, channel.__intercepts__()}
        PubSub.subscribe(pubsub_server, topic, metadata: fastlane)

        {:noreply, %{socket | joined: true}}
      end
      ```
  - 后续RoomChannel的其它callbacks会被 socket传来的其它消息触发调用（进程间消息，如phx_release, phx_close等，具体间Phoenix.Socket代码实现）
  - socket通过join_ref，channel_pid等来匹配对应的channel-server进程
    ```
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
    ```

```
# channel
iex(15)> cid = H.Process.pid 1554
iex(16)> H.Process.state(cid) |> pp
%Phoenix.Socket{
  assigns: %{
    current_user: #Slink.Accounts.User<
      __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
      id: 3,
      name: "a1@b.c",
      ...
    >
  },
  channel: SlinkWeb.RoomChannel,
  channel_pid: #PID<0.1554.0>,
  endpoint: SlinkWeb.Endpoint,
  handler: SlinkWeb.ChatSocket,
  id: "chat_socket:3",
  joined: true,
  join_ref: "3",
  private: %{log_handle_in: :debug, log_join: :info},
  pubsub_server: Slink.PubSub,
  ref: nil,
  serializer: Phoenix.Socket.V2.JSONSerializer,
  topic: "room:lobby",
  transport: :websocket,
  transport_pid: #PID<0.1546.0>
}

# socket
cid = H.Process.pid(1546)
iex(13)> H.Process.state(cid)|>pp
{%ThousandIsland.Socket{
   socket: #Port<0.105>,
   transport_module: ThousandIsland.Transports.TCP,
   read_timeout: 60000,
   silent_terminate_on_error: false,
   span: %ThousandIsland.Telemetry{
     span_name: :connection,
     telemetry_span_context: #Reference<0.2036995263.1151860737.44361>,
     start_time: -576454247933644250,
     start_metadata: %{
       handler: Bandit.DelegatingHandler,
       remote_port: 51154,
       remote_address: {127, 0, 0, 1},
       telemetry_span_context: #Reference<0.2036995263.1151860737.44361>,
       parent_telemetry_span_context: #Reference<0.2036995263.1151860737.20160>
     }
   }
 },
 %{
   connection: %Bandit.WebSocket.Connection{
     websock: SlinkWeb.ChatSocket,
     websock_state: {%{
        channels: %{
          "room:lobby" => {#PID<0.1554.0>,
           #Reference<0.2036995263.1151860737.44605>, :joined}
        },
        channels_inverse: %{#PID<0.1554.0> => {"room:lobby", "3"}}
      },
      %Phoenix.Socket{
        assigns: %{
          current_user: #Slink.Accounts.User<
            __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
            id: 3,
            name: "a1@b.c",
            ...
          >
        },
        channel: nil,
        channel_pid: nil,
        endpoint: SlinkWeb.Endpoint,
        handler: SlinkWeb.ChatSocket,
        id: "chat_socket:3",
        joined: false,
        join_ref: nil,
        private: %{},
        pubsub_server: Slink.PubSub,
        ref: nil,
        serializer: Phoenix.Socket.V2.JSONSerializer,
        topic: nil,
        transport: :websocket,
        transport_pid: #PID<0.1546.0>
      }},
     state: :open,
     compress: nil,
     opts: [
       compress: nil,
       connect_info: [
         session: {"_slink_key", Plug.Session.COOKIE,
          {"_csrf_token",
           %{
             log: :debug,
           }}}
       ],
       path: "/websocket",
       serializer: [
         {Phoenix.Socket.V2.JSONSerializer, "~> 2.0.0"}
       ],
       transport_log: :debug
     ],
     fragment_frame: nil,
     span: %Bandit.Telemetry{
       start_metadata: %{
         websock: SlinkWeb.ChatSocket,
       }
     },
     metrics: %{
       recv_text_frame_count: 9
     }
   },
   handler_module: Bandit.WebSocket.Handler,
   extractor: %Bandit.Extractor{
     header: "",
     primitive_ops_module: Bandit.PrimitiveOps.WebSocket
   }
 }}
```
## Phoenix.Socket.Transport 

```
# def connect(state)

state #=> %{
  options: [
    connect_info: [
      session: {"_slink_key", Plug.Session.COOKIE,
       {"_csrf_token",
        %{
          log: :debug,
          signing_salt: "MtbIihgV",
          serializer: :external_term_format,
          encryption_salt: nil,
          key_opts: [
            iterations: 1000,
            length: 32,
            digest: :sha256,
            cache: Plug.Keys
          ],
          rotating_options: []
        }}}
    ],
    path: "/websocket",
    serializer: [
      {Phoenix.Socket.V1.JSONSerializer, "~> 1.0.0"},
      {Phoenix.Socket.V2.JSONSerializer, "~> 2.0.0"}
    ],
    error_handler: {Phoenix.Transports.WebSocket, :handle_error, []},
    timeout: 60000,
    compress: false,
    auth_token: nil,
    transport_log: :debug
  ],
  params: %{},
  endpoint: SlinkWeb.Endpoint,
  connect_info: %{session: nil},
  transport: :websocket
}
```