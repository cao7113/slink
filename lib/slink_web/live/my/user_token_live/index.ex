defmodule SlinkWeb.My.UserTokenLive.Index do
  use SlinkWeb, :live_view

  alias Slink.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div :if={@new_api_token != nil}>
        <div class="alert alert-warning">
          Cateated API token ID={@user_token.id}!
          Keep it in safe place JUST NOW, only ONCE!!!
          <.button variant="primary" phx-click={JS.push("toggle_api_token")}>
            Toggle Visibility
          </.button>
        </div>
        <div class="alert alert-success">
          <h4 :if={@show_api_token}>{@new_api_token}</h4>
        </div>
      </div>

      <.header>
        My tokens
        <:actions>
          <.button variant="primary" phx-click={JS.push("new_api_token")}>
            <.icon name="hero-plus" /> Create API token
          </.button>
        </:actions>
      </.header>

      <.table id="user_tokens" rows={@streams.user_tokens}>
        <:col :let={{_id, user_token}} label="ID">{user_token.id}</:col>
        <:col :let={{_id, user_token}} label="Context">{user_token.context}</:col>
        <:col :let={{_id, user_token}} label="[Hashed] Token as encode16">
          {user_token.token |> Base.encode16() |> String.slice(0, 16)}...
        </:col>
        <:col :let={{_id, user_token}} label="InsertedAt">{user_token.inserted_at}</:col>
        <:action :let={{id, user_token}}>
          <.link
            :if={user_token.context == "api-token"}
            phx-click={JS.push("delete", value: %{id: user_token.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
            class="btn btn-warning"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Accounts.subscribe_user_tokens(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing My tokens")
     |> assign(:show_api_token, false)
     |> assign(:new_api_token, nil)
     |> assign(:user_token, nil)
     |> stream(:user_tokens, Accounts.list_user_tokens(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("new_api_token", _, socket) do
    scope = socket.assigns.current_scope
    user = scope.user
    {encoded_token, user_token} = Accounts.create_user_api_token(scope, user)

    socket =
      socket
      |> assign(:show_api_token, false)
      |> assign(:new_api_token, encoded_token)
      |> assign(:user_token, user_token)
      |> stream_insert(:user_tokens, user_token, at: 0)

    {:noreply, socket}
  end

  def handle_event("toggle_api_token", _, socket) do
    socket =
      socket
      |> assign(:show_api_token, !socket.assigns.show_api_token)

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    user_token = Accounts.get_user_token!(socket.assigns.current_scope, id)
    :ok = Accounts.delete_user_token(socket.assigns.current_scope, user_token)

    socket =
      socket
      |> assign(:new_api_token, nil)

    {:noreply, stream_delete(socket, :user_tokens, user_token)}
  end

  @impl true
  def handle_info({type, %Accounts.UserToken{}}, socket)
      when type in [:deleted] do
    {:noreply,
     stream(socket, :user_tokens, Accounts.list_user_tokens(socket.assigns.current_scope),
       reset: true
     )}
  end
end
