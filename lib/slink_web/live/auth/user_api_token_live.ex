defmodule SlinkWeb.UserApiTokenLive do
  use SlinkWeb, :live_view

  alias Slink.Accounts
  alias Slink.Accounts.UserToken

  @insert_index 0

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    tokens = Accounts.user_api_tokens(current_user, :all)
    {:ok, stream(socket, :api_tokens, tokens, at: @insert_index)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing API Tokens")
    |> assign(:api_token, nil)
  end

  @impl true
  def handle_event("create", %{}, socket) do
    current_user = socket.assigns.current_user
    {et, token} = Accounts.create_api_token(current_user)

    socket =
      socket
      |> assign(:new_api_token, et)

    {:noreply, stream_insert(socket, :api_tokens, token, at: @insert_index)}
  end

  @impl true
  def handle_event("delete", %{"id" => id} = _params, socket) do
    token = UserToken.find(id)
    :ok = Accounts.delete_api_token(token.token)
    socket = socket |> put_flash(:info, "token##{id} deleted")
    {:noreply, stream_delete(socket, :api_tokens, token)}
  end
end
