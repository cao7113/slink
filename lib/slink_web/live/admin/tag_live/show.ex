defmodule SlinkWeb.Admin.TagLive.Show do
  use SlinkWeb, :live_view

  alias Slink.Tags

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Tag {@tag.id}
        <:subtitle>This is a tag record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/tags"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/tags/#{@tag}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit tag
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@tag.name}</:item>
        <:item title="Desc">{@tag.desc}</:item>
        <:item title="Group">{@tag.group}</:item>
        <:item title="InsertedAt">{@tag.inserted_at}</:item>
        <:item title="UpdatedAt">{@tag.updated_at}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Tags.subscribe_tags(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Tag")
     |> assign(:tag, Tags.get_tag!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Slink.Tags.Tag{id: id} = tag},
        %{assigns: %{tag: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :tag, tag)}
  end

  def handle_info(
        {:deleted, %Slink.Tags.Tag{id: id}},
        %{assigns: %{tag: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current tag was deleted.")
     |> push_navigate(to: ~p"/admin/tags")}
  end

  def handle_info({type, %Slink.Tags.Tag{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
