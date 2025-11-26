defmodule SlinkWeb.PlayLive.Try do
  use SlinkWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="text-center">
        <.header>
          Test
          <:subtitle>Liveview test</:subtitle>
        </.header>
      </div>

      <div>
        Auto Tick: <span class="bg-blue-200">{@tick}</span>
        <.button
          class="ml-6 btn btn-secondary"
          phx-click="toggle_ticker"
        >
          {if @ticker_ref, do: "Stop Ticker", else: "Start Ticker"}
        </.button>
      </div>

      <.phone_number_input />

      <.button class="btn btn-secondary" phx-hook="ClickMeHook" id="click-me">
        Click me to get a liveview reply ref ClickMeHook in app.js!
      </.button>

      <div class="my-4">
        <.button
          class="btn btn-secondary"
          phx-click="mock-client-event"
          phx-hook=".HandleLiveviewReply"
          id="mock-event"
        >
          Click me to mock liveview push_event, see in console
        </.button>
        <script :type={Phoenix.LiveView.ColocatedHook} name=".HandleLiveviewReply">
          export default {
            mounted() {
              this.el.addEventListener("click", e => {
                this.handleEvent("mock-liveview-event", data => {
                  console.log(`reply data from liveview: ${JSON.stringify(data, null, 2)}`)
                })
              })
            }
          }
        </script>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:test_form, to_form(params))
      |> assign(:tick, 0)
      |> assign(:ticker_ref, nil)

    # ss =
    #   socket
    #   |> Map.from_struct()
    #   |> Map.reject(fn {k, _v} ->
    #     k in [:assigns, :private, :host_uri]
    #   end)

    {:ok, socket}
  end

  @impl true
  def handle_event("get_message", _params, socket) do
    # Use :reply to respond to the pushEvent
    # ref app.js ClickMeHook
    {:reply, %{message: "Hello message from LiveView in #{__MODULE__}!"}, socket}
  end

  def handle_event("inc_temperature", _params, socket) do
    {:noreply, update(socket, :temperature, &(&1 + 1))}
  end

  def handle_event("mock-client-event", _params, socket) do
    socket =
      socket
      |> push_event("mock-liveview-event", %{msg: "msg from liveview #{DateTime.utc_now()}"})

    {:noreply, socket}
  end

  @interval 1000

  def handle_event("toggle_ticker", _, socket) do
    ticker_ref = socket.assigns.ticker_ref

    if ticker_ref do
      :timer.cancel(ticker_ref)
      {:noreply, assign(socket, ticker_ref: nil)}
    else
      {:ok, ref} = :timer.send_interval(@interval, self(), :tick)
      {:noreply, assign(socket, ticker_ref: ref)}
    end
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, update(socket, :tick, &(&1 + 1))}
  end

  # https://hexdocs.pm/phoenix_live_view/js-interop.html#colocated-hooks-colocated-javascript
  def phone_number_input(assigns) do
    ~H"""
    <div class="fieldset my-6">
      <label>
        <span class="label mb-1">
          Try input 6-digits phone number like <strong>123456</strong>, auto format to <strong>1-23-456</strong>.
        </span>
      </label>
      <input
        type="text"
        name="phone_number"
        placeholder="enter a phone-number"
        id="phone-number"
        class="input max-w-100"
        phx-hook=".PhoneNumber"
      />
    </div>
    <script :type={Phoenix.LiveView.ColocatedHook} name=".PhoneNumber">
      export default {
        mounted() {
          this.el.addEventListener("input", e => {
            let match = this.el.value.replace(/\D/g, "").match(/^(\d{1})(\d{2})(\d{3})$/)
            if(match) {
              this.el.value = `${match[1]}-${match[2]}-${match[3]}`
            }
          })
        }
      }
    </script>
    """
  end
end
