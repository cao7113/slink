# Endpoint plug

http/https server 启动调用：
- Bandit.PhoenixAdapter.child_specs
- deps/bandit/lib/bandit/phoenix_adapter.ex
- 以Endpoint为Plug启动的Bandit-> Thounsand server
- 在endpoint中通过socket macro 注册的宏都会被调取到对应的child_spec callback用于管理各自额外的进程，启动时被调一次（而不是每次connect时）
- liveview只是一个特别的socket 应用

- Phoenix.Socket.PoolSupervisor 
  - 在endpoint启动的时候启动 dynamic supervisor
  - Phoenix.Socket进程 为原Plug connection进程的升级（调用sockect 自动实现的child-spec）
  - PoolSupervisor 会在对应的channel上topic 有 join消息时 由对应的dynamic supervisor调用对应的 start_child
    创建相应的channel进程（调用channel的child-spec）

```
    for scheme <- [:http, :https], opts = config[scheme] do
      ([plug: plug, display_plug: endpoint, scheme: scheme, otp_app: otp_app] ++ opts)
      |> Bandit.child_spec()
      |> Supervisor.child_spec(id: {endpoint, scheme})
    end


    iex> Ph.ep_children
    {{SlinkWeb.Endpoint, :http}, #PID<0.607.0>, :supervisor, [Bandit]}

    # in Bandit
    def child_spec(arg) do
      %{
        id: {__MODULE__, make_ref()},
        start: {__MODULE__, :start_link, [arg]},
        type: :supervisor,
        restart: :permanent
      }
    def start_link(arg) do
      ...
      |> ThousandIsland.start_link()
  end
```