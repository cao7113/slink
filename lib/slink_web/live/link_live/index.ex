defmodule SlinkWeb.LinkLive.Index do
  use SlinkWeb, :live_view
  import SlinkWeb.LinkLive.Helpers

  alias Slink.Links
  alias Slink.Links.Link

  @page_limit 20

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :links, Links.list_links(limit: @page_limit))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Links")
    |> assign(:link, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Link")
    |> assign(:link, Links.get_link!(id))
  end

  defp apply_action(socket, :new, _params) do
    link =
      %Link{user_id: socket.assigns.current_user.id}
      |> patch_new_link(Slink.build_mode())

    socket
    |> assign(:page_title, "New Link")
    |> assign(:link, link)
  end

  defp patch_new_link(link, :dev),
    do: %{
      link
      | url: "http://localhost:4000/dev/links/#{System.unique_integer([:positive])}"
    }

  defp patch_new_link(link, _), do: link

  @impl true
  def handle_info({SlinkWeb.LinkLive.FormComponent, {:saved, link}}, socket) do
    {:noreply, stream_insert(socket, :links, link, at: 0, limit: @page_limit)}
  end

  def handle_info({SlinkWeb.LinkLive.FormComponent, {:updated, link}}, socket) do
    socket =
      socket
      # reset updated link
      |> stream_delete(:links, link)
      |> stream_insert(:links, link, at: 0, limit: @page_limit)

    {:noreply, socket}
    # {:noreply, stream_insert(socket, :links, link, at: 0, limit: @page_limit)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    link = Links.get_link!(id)
    {:ok, _} = Links.delete_link(link)

    {:noreply, stream_delete(socket, :links, link)}
  end
end
