defmodule SlinkWeb.Admin.TagLive.Index do
  use SlinkWeb, :live_view

  alias Slink.Tags

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Tags
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
        <:col :let={{_id, tag}} label="Name">{tag.name}</:col>
        <:col :let={{_id, tag}} label="Group">{tag.group}</:col>
        <:col :let={{_id, tag}} label="User">{tag.user_id}</:col>
        <:col :let={{_id, tag}} label="Inserted/Updated">{tag.inserted_at}/{tag.updated_at}</:col>
        <:action :let={{_id, tag}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/tags/#{tag}"}>Show</.link>
          </div>
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
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Tags.subscribe_tags(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Tags")
     |> stream(:tags, Tags.list_tags())}
  end

  @impl true
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
