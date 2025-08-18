defmodule SlinkWeb.LinkLive.Index do
  use SlinkWeb, :live_view

  alias Slink.Links
  alias Slink.UserLinks
  require Logger

  # configured in router.ex
  # on_mount {SlinkWeb.UserAuth, :mount_current_scope}

  @per_page 20

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket) do
      Links.subscribe_links(socket.assigns.current_scope)
    end

    search_form = to_form(params)

    {:ok,
     socket
     |> assign(:page_title, "Listing Links")
     |> assign(:inline_note, false)
     |> assign(:search_form, search_form)
     |> assign(page: 1, per_page: @per_page)
     |> stream_items(query: params["query"] || "")}
  end

  @impl true
  def handle_event("search", params, socket) do
    search_form = to_form(params)

    socket =
      socket
      |> assign(:search_form, search_form)
      |> stream_items(query: params["query"], page: 1)

    {:noreply, socket}
  end

  def handle_event("next-page", _, socket) do
    query = socket.assigns.search_form.params["query"]
    {:noreply, stream_items(socket, query: query, page: socket.assigns.page + 1)}
  end

  def handle_event("prev-page", %{"_overran" => true}, socket) do
    query = socket.assigns.search_form.params["query"]
    {:noreply, stream_items(socket, query: query, page: 1)}
  end

  def handle_event("prev-page", _, socket) do
    if socket.assigns.page > 1 do
      query = socket.assigns.search_form.params["query"]
      {:noreply, stream_items(socket, query: query, page: socket.assigns.page - 1)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("open_link", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    {:ok, log} = Links.create_link_log(scope, %{link_id: id, event: "opened"})
    Logger.debug("opened link #{log |> inspect}")
    {:noreply, socket}
  end

  def handle_event("toggle_favor", %{"id" => id}, socket) do
    link = Links.get_link!(id)
    scope = socket.assigns.current_scope
    {:ok, ulink} = UserLinks.toggle_favor(scope, link)
    link = %{link | my_ulink: ulink}
    socket = stream_insert(socket, :links, link, update_only: true)
    {:noreply, socket}
  end

  def handle_event("toggle_inline_note", %{}, socket) do
    query = socket.assigns.search_form.params["query"]

    socket =
      socket
      |> assign(:inline_note, !socket.assigns.inline_note)
      |> stream_items(query: query)

    {:noreply, socket}
  end

  def handle_event("update_note", %{"id" => id, "value" => new_note}, socket) do
    link = Links.get_link!(id)
    scope = socket.assigns.current_scope
    {:ok, ulink} = UserLinks.update_note(scope, link, new_note)
    link = %{link | my_ulink: ulink}
    socket = stream_insert(socket, :links, link, update_only: true)
    # query = socket.assigns.search_form.params["query"]
    # socket = stream_items(socket, query: query)
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    link = Links.get_link!(socket.assigns.current_scope, id)
    # NOTE: publish delete event handled by handle_info()
    {:ok, _} = Links.delete_link(socket.assigns.current_scope, link)
    socket = stream_delete(socket, :links, link)
    {:noreply, socket}
  end

  @impl true
  def handle_info({type, %Slink.Links.Link{}}, socket)
      when type in [:created, :updated, :deleted] do
    query = socket.assigns.search_form.params["query"]
    socket = stream_items(socket, query: query)
    {:noreply, socket}
  end

  @doc """
  Stream items with pagination
  """
  def stream_items(socket, opts \\ []) do
    %{per_page: per_page, page: cur_page} = socket.assigns
    query = Keyword.get(opts, :query, "")
    new_page = Keyword.get(opts, :page, 1) |> get_page()

    total_count = Links.search_links_count(query)
    items = Links.search_links(socket, query, page: new_page, per_page: per_page)

    socket =
      socket
      |> assign(:links_count, total_count)

    {items, at, limit} =
      if new_page >= cur_page do
        {items, -1, per_page * 3 * -1}
      else
        {Enum.reverse(items), 0, per_page * 3}
      end

    case items do
      [] ->
        socket
        |> assign(end_of_timeline?: at == -1)
        |> stream(:links, [])

      [_ | _] = items ->
        socket
        |> assign(end_of_timeline?: false)
        |> assign(:page, new_page)
        |> stream(:links, items, at: at, limit: limit, reset: true)
    end
  end

  def get_page(nil), do: 1
  def get_page(page) when is_integer(page) and page >= 1, do: page
  def get_page(page) when is_binary(page), do: page |> String.to_integer() |> get_page()

  # @impl true
  # def render(assigns) do
  #   ~H"""
  #   <Layouts.app flash={@flash} current_scope={@current_scope}>
  #     <span>Nothing here, already moved into index.html.heex!</span>
  #   </Layouts.app>
  #   """
  # end
end
