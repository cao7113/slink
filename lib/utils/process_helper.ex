defmodule ProcessHelper do
  @doc """
  Get process id
  iex also support: pid(0, 21, 32)
  """
  def pid(pid) when is_pid(pid), do: pid
  def pid(name) when is_atom(name), do: Process.whereis(name)
  # GenServer.whereis(aGenServer)

  def pid("#PID<" <> pstr), do: pstr |> String.trim_trailing(">") |> pid()
  def pid("PID<" <> pstr), do: pstr |> String.trim_trailing(">") |> pid()
  def pid("<" <> pstr), do: pstr |> String.trim_trailing(">") |> pid()

  # https://github.com/elixir-lang/elixir/blob/v1.14.0/lib/iex/lib/iex/helpers.ex#L1248
  # iex> pid("0.664.0") # => #PID<0.664.0>
  def pid(string) when is_binary(string) do
    :erlang.list_to_pid(~c"<#{string}>")
  end

  @doc """
  Get process info
  """
  def pinfo(name_or_pid) do
    name_or_pid
    |> pid()
    |> Process.info()
  end

  ## Debuging with :sys.xxx as https://hexdocs.pm/elixir/GenServer.html#module-debugging-with-the-sys-module
  def state(name_or_pid, opts \\ []) do
    name_or_pid
    |> pid()
    |> case do
      nil ->
        :not_found_pid

      p ->
        timeout = Keyword.get(opts, :timeout, 200)
        :sys.get_state(p, timeout)
    end
  end

  def status(name_or_pid) do
    name_or_pid
    |> pid()
    |> case do
      nil -> :not_found_pid
      p -> :sys.get_status(p)
    end
  end

  @doc """
  Get child pid of a supervisor
  """
  def child_pid(sup, child_id)
      when is_atom(sup) and (is_atom(child_id) or is_binary(child_id)) do
    sup
    |> Supervisor.which_children()
    |> Enum.find(fn {id, _pid, _tp, _mods} ->
      id == child_id
    end)
    |> case do
      nil -> {:error, :not_found_child}
      {_id, pid, _tp, _mods} -> pid
    end
  end

  def restart_child(sup, child_id) do
    with :ok <- Supervisor.terminate_child(sup, child_id) do
      Supervisor.restart_child(sup, child_id)
    end
  end

  def remove_child(sup, child_id) do
    with :ok <- Supervisor.terminate_child(sup, child_id) do
      Supervisor.delete_child(sup, child_id)
    end
  end

  @doc """
  Returns the operating system PID for the current Erlang runtime system instance.
  """
  def system_pid(), do: System.pid() |> String.to_integer()
end
