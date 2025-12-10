defmodule SlinkWeb.PlayLive.Shuffer do
  alias SlinkWeb.Layouts
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div>
        <div>
          Counter: {@counter}
          <button class="btn" phx-click="inc">+</button>
        </div>

        <MySortComponent.display lists={[first_list: @first_list, second_list: @second_list]} />
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    first_list = for(i <- 1..9, do: "First List #{i}") |> Enum.shuffle()
    second_list = for(i <- 1..9, do: "Second List #{i}") |> Enum.shuffle()

    socket =
      socket
      |> assign(:counter, 0)
      |> assign(first_list: first_list)
      |> assign(second_list: second_list)
      # 2) Delegated events
      |> attach_hook(:sort, :handle_event, &MySortComponent.hooked_event/3)

    # ss = socket |> Map.from_struct()

    {:ok, socket}
  end

  # 1) Normal event
  def handle_event("inc", _params, socket) do
    {:noreply, update(socket, :counter, &(&1 + 1))}
  end
end

defmodule MySortComponent do
  use Phoenix.Component

  def display(assigns) do
    ~H"""
    <div class="flex gap-8">
      <div :for={{key, list} <- @lists}>
        <ul>
          <li :for={item <- list}>{item}</li>
        </ul>
        <button phx-click="shuffle" phx-value-list={key} class="btn">Shuffle</button>
        <button phx-click="sort" phx-value-list={key} class="btn">Sort</button>
      </div>
    </div>
    """
  end

  def hooked_event("shuffle", %{"list" => key}, socket) do
    key = String.to_existing_atom(key)
    shuffled = Enum.shuffle(socket.assigns[key])

    {:halt, assign(socket, key, shuffled)}
  end

  def hooked_event("sort", %{"list" => key}, socket) do
    key = String.to_existing_atom(key)
    sorted = Enum.sort(socket.assigns[key])

    {:halt, assign(socket, key, sorted)}
  end

  def hooked_event(_event, _params, socket), do: {:cont, socket}
end
