defmodule SlinkWeb.LinkLive.Show do
  use SlinkWeb, :live_view
  import SlinkWeb.LinkLive.Helpers

  alias Slink.Links

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:link, Links.get_link!(id))}
  end

  defp page_title(:show), do: "Show Link"
  defp page_title(:edit), do: "Edit Link"
end
