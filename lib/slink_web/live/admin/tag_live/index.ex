defmodule SlinkWeb.Admin.TagLive.Index do
  use SlinkWeb, :live_view

  alias Slink.Tags

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.form for={@search_form} id="search-form" phx-change="search">
        <.input
          type="search"
          field={@search_form[:query]}
          placeholder="Search tag name..."
          phx-debounce="300"
          class="input input-lg w-3/4"
        />
      </.form>

      <.header>
        Listing Tags({@streams.tags |> Enum.count()})
        <:actions>
          <.button variant="primary" navigate={~p"/admin/tags/new"}>
            <.icon name="hero-plus" /> New Tag
          </.button>
        </:actions>
      </.header>

      <.table
        id="tags"
        rows={@streams.tags}
        row_click={fn {_id, tag} -> JS.navigate(~p"/admin/tags/#{tag}") end}
      >
        <:col :let={{_id, tag}} label="ID">{tag.id}</:col>
        <:col :let={{_id, tag}} label="Name">{tag.name}</:col>
        <:col :let={{_id, tag}} label="Desc">
          <div class="max-w-20 truncate">{tag.desc}</div>
        </:col>
        <:col :let={{_id, tag}} label="Group">{tag.group}</:col>
        <:col :let={{_id, tag}} label="Links Count">{tag.links_count}</:col>
        <:col :let={{_id, tag}} label="User">{tag.user_id}</:col>
        <:col :let={{_id, tag}} label="Inserted/Updated">{tag.inserted_at}/{tag.updated_at}</:col>
        <:action :let={{_id, tag}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/tags/#{tag}"}>Show</.link>
          </div>

          <.link navigate={~p"/admin/tags/#{tag}/migrate"}>Migrate</.link>
          <.link navigate={~p"/admin/tags/#{tag}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, tag}}>
          <.link
            phx-click={JS.push("delete", value: %{id: tag.id}) |> hide("##{id}")}
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
      Tags.subscribe_tags(socket.assigns.current_scope)
    end

    search_form = to_form(params)
    q = (params["query"] || "") |> String.trim()

    {:ok,
     socket
     |> assign(:page_title, "Listing Tags")
     |> assign(:search_form, search_form)
     |> stream(:tags, Tags.search_tags(q))}
  end

  @impl true
  def handle_event("search", params, socket) do
    search_form = to_form(params)
    q = (params["query"] || "") |> String.trim()

    socket =
      socket
      |> assign(:search_form, search_form)
      |> stream(:tags, Tags.search_tags(q), reset: true)

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    tag = Tags.get_tag!(socket.assigns.current_scope, id)
    {:ok, _} = Tags.delete_tag(socket.assigns.current_scope, tag)

    {:noreply, stream_delete(socket, :tags, tag)}
  end

  @impl true
  def handle_info({type, %Slink.Tags.Tag{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :tags, Tags.list_tags(socket.assigns.current_scope), reset: true)}
  end
end
