defmodule SlinkWeb.Admin.SiteLive.Show do
  use SlinkWeb, :live_view

  alias Slink.Sites

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Site {@site.id}
        <:subtitle>This is a site record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/sites"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/sites/#{@site}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit site
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="ID">{@site.id}</:item>
        <:item title="Name">{@site.name}</:item>
        <:item title="Url">{@site.url}</:item>
        <:item title="Logo url">{@site.logo_url}</:item>
        <:item title="Category">{@site.category}</:item>
        <:item title="Intro">{@site.intro}</:item>
        <:item title="InsertedAt">{@site.inserted_at}</:item>
        <:item title="UpdatedAt">{@site.updated_at}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Sites.subscribe_sites(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Site")
     |> assign(:site, Sites.get_site!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Slink.Sites.Site{id: id} = site},
        %{assigns: %{site: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :site, site)}
  end

  def handle_info(
        {:deleted, %Slink.Sites.Site{id: id}},
        %{assigns: %{site: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current site was deleted.")
     |> push_navigate(to: ~p"/admin/sites")}
  end

  def handle_info({type, %Slink.Sites.Site{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
