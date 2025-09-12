defmodule SlinkWeb.LinkLive.Index do
  use SlinkWeb, :live_view

  alias Slink.Links
  alias Slink.UserLinks
  require Logger

  @per_page 50

  @impl true
  def mount(params, _session, socket) do
    scope = socket.assigns.current_scope

    if connected?(socket) do
      Links.subscribe_links(scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Links")
     |> assign(:pin_user_links, get_top_pinned_links(scope))
     |> assign(:inline_note, false)
     |> assign(:search_form, to_form(params))
     |> assign(:kind, "latest")
     |> assign(:tag_id, get_init_tag_id(params))
     |> assign(:site_id, get_init_site_id(params))
     |> assign(page: get_page(params["page"]), per_page: @per_page)
     |> stream_items()}
  end

  @impl true
  def handle_event("search", params, socket) do
    socket =
      socket
      |> assign(:search_form, to_form(params))
      # set current page to 1 every search
      |> assign(:page, 1)
      |> stream_items(page: 1)

    {:noreply, socket}
  end

  # https://hexdocs.pm/phoenix_live_view/1.1.0-rc.4/bindings.html#scroll-events-and-infinite-pagination
  def handle_event("prev-page", %{"_overran" => true} = _params, socket) do
    {:noreply, stream_items(socket, page: 1)}
  end

  def handle_event("prev-page", _params, socket) do
    if socket.assigns.page > 1 do
      {:noreply, stream_items(socket, page: socket.assigns.page - 1)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("next-page", _params, socket) do
    {:noreply, stream_items(socket, page: socket.assigns.page + 1)}
  end

  def handle_event("change_kind", %{"kind" => kind}, socket) do
    socket =
      socket
      |> assign(:kind, kind)
      |> assign(:page, 1)
      |> stream_items()

    {:noreply, socket}
  end

  def handle_event("open_link", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    {:ok, log} = Links.create_link_log(scope, %{link_id: id, event: "opened"})
    Logger.debug("opened link #{log |> inspect}")
    {:noreply, socket}
  end

  def handle_event("toggle_favor", %{"id" => id}, socket) do
    link = Links.get_link_with_resources(id)
    scope = socket.assigns.current_scope
    {:ok, ulink} = UserLinks.toggle_favor(scope, link)
    link = %{link | my_ulink: ulink}
    socket = stream_insert(socket, :links, link, update_only: true)
    {:noreply, socket}
  end

  def handle_event("toggle_pin", %{"id" => id}, socket) do
    link = Links.get_link_with_resources(id)
    scope = socket.assigns.current_scope
    {:ok, ulink} = UserLinks.toggle_pin(scope, link)
    link = %{link | my_ulink: ulink}

    socket =
      socket
      |> assign(:pin_user_links, get_top_pinned_links(scope))
      |> stream_insert(:links, link, update_only: true)

    {:noreply, socket}
  end

  def handle_event("update_note", %{"id" => id, "value" => new_note}, socket) do
    link = Links.get_link_with_resources(id)
    scope = socket.assigns.current_scope
    {:ok, ulink} = UserLinks.update_note(scope, link, new_note)
    link = %{link | my_ulink: ulink}
    socket = stream_insert(socket, :links, link, update_only: true)
    {:noreply, socket}
  end

  def handle_event("toggle_inline_note", %{}, socket) do
    socket =
      socket
      |> assign(:inline_note, !socket.assigns.inline_note)
      |> stream_items()

    {:noreply, socket}
  end

  def handle_event("toggle_tag_id", %{"id" => id}, socket) do
    new_id = if socket.assigns.tag_id == id, do: nil, else: id

    socket =
      socket
      |> assign(:tag_id, new_id)
      |> assign(:page, 1)
      |> stream_items(page: 1)

    {:noreply, socket}
  end

  def handle_event("toggle_site_id", %{"id" => id}, socket) do
    new_id = if socket.assigns.site_id == id, do: nil, else: id

    socket =
      socket
      |> assign(:site_id, new_id)
      |> assign(:page, 1)
      |> stream_items(page: 1)

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    link = Links.get_link!(socket.assigns.current_scope, id)
    # NOTE: publish delete event handled by handle_info()
    {:ok, _} = Links.delete_link(socket.assigns.current_scope, link)
    socket = stream_delete(socket, :links, link)
    {:noreply, socket}
  end

  def handle_event("_try", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({type, %Slink.Links.Link{}}, socket)
      when type in [:created, :updated, :deleted] do
    socket = stream_items(socket)
    {:noreply, socket}
  end

  @doc """
  Stream items with pagination
  """
  def stream_items(socket, opts \\ []) do
    q = socket.assigns.search_form.params |> Map.get("q", "")
    %{page: cur_page, per_page: per_page} = socket.assigns
    new_page = Keyword.get(opts, :page, 1) |> get_page()

    search_info =
      socket.assigns
      # socket.assigns is a map
      |> Map.take([:current_scope, :kind, :tag_id, :site_id, :page, :per_page])
      |> Map.to_list()
      |> Keyword.put(:q, q)

    total_count = Links.search_links_count(search_info)
    items = Links.search_links(search_info)

    socket =
      socket
      |> assign(:links_count, total_count)

    num_pages = 3

    {items, at, limit} =
      if new_page >= cur_page do
        {items, -1, per_page * num_pages * -1}
      else
        {Enum.reverse(items), 0, per_page * num_pages}
      end

    if Builder.is_dev?() do
      Logger.warning(
        "current-page=#{cur_page} new-page=#{new_page} total-count=#{total_count}  #{Enum.count(items)} items found!"
      )
    end

    case items do
      [] ->
        socket
        |> assign(end_of_timeline?: at == -1)
        |> stream(:links, [], reset: total_count == 0)

      [_ | _] = items ->
        socket
        |> assign(end_of_timeline?: false)
        |> assign(:page, new_page)
        |> stream(:links, items, at: at, limit: limit, reset: total_count <= per_page)
    end
  end

  def get_top_pinned_links(scope) do
    if scope, do: UserLinks.top_pinned_user_links(scope, 3), else: []
  end

  def get_page(nil), do: 1
  def get_page(page) when is_integer(page) and page >= 1, do: page
  def get_page(page) when is_binary(page), do: page |> String.to_integer() |> get_page()

  def get_init_tag_id(params) do
    tag =
      case params["tag_id"] do
        nil ->
          case params["tag"] do
            nil -> nil
            name -> Slink.Tags.get_by_name(name)
          end

        id ->
          Slink.Tags.get_tag(id)
      end

    if tag, do: tag.id, else: nil
  end

  def get_init_site_id(params) do
    site =
      case params["site_id"] do
        nil ->
          case params["site"] do
            nil -> nil
            name -> Slink.Sites.get_by_name(name)
          end

        id ->
          Slink.Sites.get_site(id)
      end

    if site, do: site.id, else: nil
  end
end
