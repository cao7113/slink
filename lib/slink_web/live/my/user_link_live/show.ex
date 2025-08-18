defmodule SlinkWeb.My.UserLinkLive.Show do
  use SlinkWeb, :live_view

  alias Slink.UserLinks

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        User link {@user_link.id}
        <:subtitle>This is a user_link record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/my/user_links"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/my/user_links/#{@user_link}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit user_link
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@user_link.title}</:item>
        <:item title="Note">{@user_link.note}</:item>
        <:item title="Favor at">{@user_link.favor_at}</:item>
        <:item title="Last visit at">{@user_link.last_visit_at}</:item>
        <:item title="Total visit times">{@user_link.total_visit_times}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      UserLinks.subscribe_user_links(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show User link")
     |> assign(:user_link, UserLinks.get_user_link!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Slink.Links.UserLink{id: id} = user_link},
        %{assigns: %{user_link: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :user_link, user_link)}
  end

  def handle_info(
        {:deleted, %Slink.Links.UserLink{id: id}},
        %{assigns: %{user_link: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current user_link was deleted.")
     |> push_navigate(to: ~p"/my/user_links")}
  end

  def handle_info({type, %Slink.Links.UserLink{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
