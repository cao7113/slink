defmodule SlinkWeb.My.UserLinkLive.Index do
  use SlinkWeb, :live_view

  alias Slink.UserLinks

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing User links
      </.header>

      <.table
        id="user_links"
        rows={@streams.user_links}
        row_click={fn {_id, user_link} -> JS.navigate(~p"/my/user_links/#{user_link}") end}
      >
        <:col :let={{_id, user_link}} label="Title">{user_link.title}</:col>
        <:col :let={{_id, user_link}} label="Note">{user_link.note}</:col>
        <:col :let={{_id, user_link}} label="Favor at">{user_link.favor_at}</:col>
        <:col :let={{_id, user_link}} label="Last visit at">{user_link.last_visit_at}</:col>
        <:col :let={{_id, user_link}} label="Total visit times">{user_link.total_visit_times}</:col>
        <:action :let={{_id, user_link}}>
          <div class="sr-only">
            <.link navigate={~p"/my/user_links/#{user_link}"}>Show</.link>
          </div>
          <.link navigate={~p"/my/user_links/#{user_link}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, user_link}}>
          <.link
            phx-click={JS.push("delete", value: %{id: user_link.id}) |> hide("##{id}")}
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
      UserLinks.subscribe_user_links(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing User links")
     |> stream(:user_links, UserLinks.list_user_links(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user_link = UserLinks.get_user_link!(socket.assigns.current_scope, id)
    {:ok, _} = UserLinks.delete_user_link(socket.assigns.current_scope, user_link)

    {:noreply, stream_delete(socket, :user_links, user_link)}
  end

  @impl true
  def handle_info({type, %Slink.Links.UserLink{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :user_links, UserLinks.list_user_links(socket.assigns.current_scope),
       reset: true
     )}
  end
end
