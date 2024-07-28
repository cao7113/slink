defmodule SlinkWeb.LinkLive.Index do
  require Logger
  use SlinkWeb, :live_view
  import SlinkWeb.LinkLive.Helpers

  alias Slink.Links
  alias Slink.Links.Link

  # on_mount {SlinkWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    Logger.debug("LinkLive.Index mounting in live-action: #{socket.assigns.live_action}")
    {:ok, stream(socket, :links, Links.list_links())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    Logger.debug("handle_params in live-action: #{socket.assigns.live_action}")
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Link")
    |> assign(:link, Links.get_link!(id))
  end

  defp apply_action(socket, :new, _params) do
    link = %Link{user_id: socket.assigns.current_user.id}

    link =
      if Slink.build_mode() == :dev do
        %{
          link
          | url: "http://localhost:4000/dev/links/#{System.unique_integer([:positive])}"
        }
      else
        link
      end

    socket
    |> assign(:page_title, "New Link")
    |> assign(:link, link)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Links")
    |> assign(:link, nil)
  end

  @impl true
  def handle_info({SlinkWeb.LinkLive.FormComponent, {:saved, link}}, socket) do
    {:noreply, stream_insert(socket, :links, link, at: 0, limit: 20)}
  end

  def handle_info({SlinkWeb.LinkLive.FormComponent, {:updated, link}}, socket) do
    socket =
      socket
      # reset updated link
      |> stream_delete(:links, link)
      |> stream_insert(:links, link, at: 0, limit: 20)

    {:noreply, socket}
    # {:noreply, stream_insert(socket, :links, link, at: 0, limit: 20)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    link = Links.get_link!(id)
    {:ok, _} = Links.delete_link(link)

    {:noreply, stream_delete(socket, :links, link)}
  end
end
