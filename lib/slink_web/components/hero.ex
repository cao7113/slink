defmodule SlinkWeb.Comp.Hero do
  @moduledoc """
  A simple hero component to as live_compoenent example.

  <.live_component module={HeroComponent} id="hero" content={@content} />
  """

  use SlinkWeb, :live_component
  require Logger

  @impl true
  def render(assigns) do
    Logger.debug("Hero component render with pid: #{inspect(assigns)}")

    ~H"""
    <div class="hero">
      {@content} self-pid: {inspect(self())}
      <a href="#" phx-click="say_hello" phx-target={@myself}>
        Say hello!
      </a>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    Logger.debug("Hero component mounted with socket: #{inspect(socket)}")
    socket = assign(socket, :content, "Welcome Hero Component!")
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    Logger.debug("Hero component updated with assigns: #{inspect(assigns)}")
    socket = assign(socket, assigns)
    {:ok, socket}
  end

  @impl true
  def handle_event("say_hello", _value, socket) do
    Logger.info("Hello from Hero component with pid: #{inspect(self())}")
    {:noreply, socket}
  end
end
