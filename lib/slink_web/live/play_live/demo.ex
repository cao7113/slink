defmodule SlinkWeb.PlayLive.Demo do
  @moduledoc """
  Basic Liveview demo
  liveview is just a process(channel)

  """

  use Phoenix.LiveView
  alias SlinkWeb.Layouts

  @process_name :live_demo
  def process_name, do: @process_name

  attr :name, :string, default: "boy"

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div>Hello {@name}</div>
      <div>
        Update name on input-blur: <input phx-blur="update_name" class="input w-40" value={@name} />
      </div>

      <div>
        Counter: {@counter}
        <button class="btn btn-active" phx-click="inc">+</button>
      </div>

      <div>Current time: {@date} (UTC)</div>
      <div>Current pid {self() |> inspect} as process-name {process_name() |> inspect}</div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, session, socket) do
    if connected?(socket) do
      register_process_name(process_name())
      {:ok, _tref} = :timer.send_interval(1000, self(), :tick)
    end

    {params, session, socket} |> dbg

    socket =
      socket
      |> assign(:counter, 0)
      |> assign(date: DateTime.utc_now())

    {:ok, socket}
  end

  @impl true
  def handle_event("inc", _params, socket) do
    {:handle_event, self(), socket} |> dbg
    {:noreply, update(socket, :counter, &(&1 + 1))}
  end

  def handle_event("update_name", %{"value" => new_name}, socket) do
    # todo maybe too long
    {:noreply, assign(socket, :name, new_name)}
  end

  @impl true
  @doc """
  iex> send(:live_demo, {:update_name, "new name"})
  iex> pstate(:live_demo).socket.assigns
  """
  def handle_info({:update_name, name}, socket) do
    socket = socket |> assign(:name, name)
    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, date: DateTime.utc_now())}
  end

  def register_process_name(name, pid \\ self()) do
    Process.whereis(name)
    |> case do
      nil -> nil
      # prepare for new binding if already registered
      _pid -> Process.unregister(name)
    end

    Process.register(pid, :live_demo)
  end
end
