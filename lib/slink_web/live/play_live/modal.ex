defmodule SlinkWeb.PlayLive.Modal do
  @moduledoc """
  Tag modal try
  """

  use SlinkWeb, :live_view
  alias Phoenix.LiveView.JS
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.live_component
        module={SlinkWeb.Comp.Hero}
        id="hero-id1"
        content="demo live-component as hero"
      />
      <div>Current pid {inspect(self())} in liveview</div>

      <div>
        <div id="item">My Item</div>
        <button phx-click={JS.toggle_class("bg-blue-200 underline", to: "#item")}>
          highlight!
        </button>
      </div>

      <div phx-click={JS.show(to: {:inner, ".menu"})}>
        <div>Open me</div>
        <div class="menu hidden" phx-click-away={JS.hide()}>
          I'm in the dropdown menu
        </div>
      </div>

      <button phx-click={JS.toggle_class("modal-open", to: "#my_modal_2")}>Open Modal</button>
      <div>Current counter: {@counter}</div>

      <button class="btn" phx-click="toggle-modal" onclick="my_modal_2.showModal()">
        open modal
      </button>

      <dialog id="my_modal_2" class={["modal", if(@modal_open, do: "modal-open")]}>
        <div class="modal-box">
          <form method="dialog">
            <button
              phx-click="toggle-modal"
              class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2"
            >
              ✕
            </button>
          </form>
          <h3 class="text-lg font-bold">Hello!</h3>
          <p class="py-4">Press ESC key or click outside to close</p>
          <button phx-click={JS.toggle_class("modal-open", to: "#my_modal_2")}>Toggle Modal</button>

          <.link phx-click="inc" class="btn btn-primary">Increment: {@counter}</.link>

          <div class="modal-action">
            <form method="dialog">
              <!-- if there is a button in form, it will close the modal -->
              <button class="btn" phx-click="toggle-modal">Close</button>
            </form>
          </div>
        </div>
        <form method="dialog" class="modal-backdrop">
          <button phx-click="toggle-modal">close</button>
        </form>
      </dialog>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # in live connection
    end

    socket =
      socket
      |> assign(:modal_open, false)
      |> assign(:counter, 0)

    Logger.debug("Mounted Tag Live View with socket: #{inspect(socket.assigns)}")

    {:ok, socket}
  end

  def hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(transition: "fade-out", to: "#modal")
    |> JS.hide(transition: "fade-out-scale", to: "#modal-content")
  end

  def modal(assigns) do
    ~H"""
    <div id="modal" class="phx-modal" phx-remove={hide_modal()}>
      <div
        id="modal-content"
        class="phx-modal-content"
        phx-click-away={hide_modal()}
        phx-window-keydown={hide_modal()}
        phx-key="escape"
      >
        <button class="phx-modal-close" phx-click={hide_modal()}>✖</button>
        <p>{@text}</p>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("inc", _params, socket) do
    {:noreply, update(socket, :counter, &(&1 + 1))}
  end

  def handle_event("toggle-modal", _params, socket) do
    {:noreply, assign(socket, :modal_open, !socket.assigns.modal_open)}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, assign(socket, date: DateTime.utc_now())}
  end
end
