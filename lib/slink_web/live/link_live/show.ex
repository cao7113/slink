defmodule SlinkWeb.LinkLive.Show do
  use SlinkWeb, :live_view

  alias Slink.Links

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Link {@link.id}
        <:subtitle>This is a link record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/links"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            :if={@current_scope && @current_scope.user.id == @link.user_id}
            variant="primary"
            navigate={~p"/links/#{@link}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit link
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="ID">{@link.id}</:item>
        <:item title="Title">{@link.title}</:item>
        <:item title="Url">
          <.link href={@link.url} class="link link-hover text-blue-600 truncate max-w-[80%]">
            {@link.url}
          </.link>
        </:item>
        <:item title="Tags">
          <%= for tag <- @link.tags do %>
            <span class="badge badge-accent">{tag.name}</span>
          <% end %>
        </:item>
        <:item title="User">{@link.user_id}</:item>
        <:item title="Inserted At">{@link.inserted_at}</:item>
        <:item title="Updated At">{@link.updated_at}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Links.subscribe_links(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Link")
     |> assign(:link, Links.get_link_with_tags!(id))}
  end

  @impl true
  def handle_info(
        {:updated, %Slink.Links.Link{id: id} = link},
        %{assigns: %{link: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :link, link)}
  end

  def handle_info(
        {:deleted, %Slink.Links.Link{id: id}},
        %{assigns: %{link: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current link was deleted.")
     |> push_navigate(to: ~p"/links")}
  end

  def handle_info({type, %Slink.Links.Link{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
