defmodule SlinkWeb.Admin.SiteLive.Index do
  use SlinkWeb, :live_view

  alias Slink.Sites

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.form for={@search_form} id="search-form" phx-change="search">
        <.input
          type="search"
          field={@search_form[:query]}
          placeholder="Search site name or url..."
          phx-debounce="300"
          class="input input-lg w-3/4"
        />
      </.form>

      <.header>
        Listing Sites({@streams.sites |> Enum.count()})
        <:actions>
          <.button variant="primary" navigate={~p"/admin/sites/new"}>
            <.icon name="hero-plus" /> New Site
          </.button>
        </:actions>
      </.header>

      <.table
        id="sites"
        rows={@streams.sites}
        row_click={fn {_id, site} -> JS.navigate(~p"/admin/sites/#{site}") end}
      >
        <:col :let={{_id, site}} label="ID">{site.id}</:col>
        <:col :let={{_id, site}} label="Name">{site.name}</:col>
        <:col :let={{_id, site}} label="Url">
          <.link href={site.url} class="link" target="_blank">{site.url}</.link>
        </:col>
        <:col :let={{_id, site}} label="Category">{site.category}</:col>
        <:col :let={{_id, site}} label="Inserted/Updated">{site.inserted_at}/{site.updated_at}</:col>
        <:action :let={{_id, site}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/sites/#{site}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/sites/#{site}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, site}}>
          <.link
            phx-click={JS.push("delete", value: %{id: site.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket) do
      Sites.subscribe_sites(socket.assigns.current_scope)
    end

    search_form = to_form(params)
    q = (params["query"] || "") |> String.trim()

    {:ok,
     socket
     |> assign(:page_title, "Listing Sites")
     |> assign(:search_form, search_form)
     |> stream(:sites, Sites.search_sites(q))}
  end

  @impl true
  def handle_event("search", params, socket) do
    search_form = to_form(params)
    q = (params["query"] || "") |> String.trim()

    socket =
      socket
      |> assign(:search_form, search_form)
      |> stream(:sites, Sites.search_sites(q), reset: true)

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    site = Sites.get_site!(socket.assigns.current_scope, id)
    {:ok, _} = Sites.delete_site(socket.assigns.current_scope, site)

    {:noreply, stream_delete(socket, :sites, site)}
  end

  @impl true
  def handle_info({type, %Slink.Sites.Site{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :sites, Sites.list_sites(socket.assigns.current_scope), reset: true)}
  end
end
