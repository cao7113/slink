defmodule SlinkWeb.Admin.UserLive.Index do
  use SlinkWeb, :live_view

  alias Slink.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Users
      </.header>

      <.table
        id="users"
        rows={@streams.users}
        row_click={fn {_id, user} -> JS.navigate(~p"/admin/users/#{user}") end}
      >
        <:col :let={{_id, user}} label="Email">{user.email}</:col>
        <:col :let={{_id, user}} label="Name">{user.name}</:col>
        <:col :let={{_id, user}} label="Admin">{user.admin_role}</:col>
        <:col :let={{_id, user}} label="ConfirmedAt">{user.confirmed_at}</:col>
        <:col :let={{_id, user}} label="InsertedAt">{user.inserted_at}</:col>
        <:col :let={{_id, user}} label="UpdatedAt">{user.updated_at}</:col>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    # if connected?(socket) do
    #   Accounts.subscribe_users(socket.assigns.current_scope)
    # end

    {:ok,
     socket
     |> assign(:page_title, "Listing Users")
     |> stream(:users, Accounts.list_users(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    _user = Accounts.get_user!(id)
    # {:ok, _} = Accounts.delete_user(user)

    {:noreply, socket}
  end

  # @impl true
  # def handle_info({type, %Slink.Accounts.User{}}, socket)
  #     when type in [:created, :updated, :deleted] do
  #   {:noreply,
  #    stream(socket, :users, Accounts.list_users(socket.assigns.current_scope), reset: true)}
  # end
end
