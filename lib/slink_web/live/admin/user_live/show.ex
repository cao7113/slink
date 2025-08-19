defmodule SlinkWeb.Admin.UserLive.Show do
  use SlinkWeb, :live_view

  alias Slink.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        User {@user.id}
        <:subtitle>This is a user record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/users"}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Email">{@user.email}</:item>
        <:item title="Name">{@user.name}</:item>
        <:item title="Admin role">{@user.admin_role}</:item>
        <:item title="Site">{@user.site}</:item>
        <:item title="AvatarUrL">{@user.avatar_url}</:item>
        <:item title="Confirmed at">{@user.confirmed_at}</:item>
        <:item title="Inserted at">{@user.inserted_at}</:item>
        <:item title="Updated at">{@user.updated_at}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # if connected?(socket) do
    #   Accounts.subscribe_users(socket.assigns.current_scope)
    # end

    {:ok,
     socket
     |> assign(:page_title, "Show User")
     |> assign(:user, Accounts.get_user!(id))}
  end

  @impl true
  def handle_info(
        {:updated, %Slink.Accounts.User{id: id} = user},
        %{assigns: %{user: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :user, user)}
  end

  def handle_info({type, %Slink.Accounts.User{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
