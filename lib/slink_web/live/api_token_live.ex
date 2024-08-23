defmodule SlinkWeb.ApiTokenLive do
  use SlinkWeb, :live_view

  alias Slink.Accounts
  alias Slink.Accounts.UserToken
  alias Slink.Repo

  @per_page 10

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page: 1, per_page: @per_page)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    current_user = socket.assigns.current_user
    query = Accounts.list_api_tokens_query(current_user, :all)
    total_info = Accounts.total_pages_info_of(query, @per_page)

    socket =
      socket
      |> assign(:page_title, "Listing API Tokens")
      |> assign(total_info)
      |> assign(:api_token, nil)
      |> paginate_tokens(current_user, 1)

    {:noreply, socket}
  end

  @impl true
  def handle_event("create", %{}, socket) do
    current_user = socket.assigns.current_user
    {et, token} = Accounts.create_api_token(current_user)

    socket =
      socket
      |> assign(:new_api_token, et)
      |> push_event("highlight", %{id: "api_tokens-#{token.id}"})

    # {:noreply, stream_insert(socket, :api_tokens, token, at: 0)}
    {:noreply, push_patch(socket, to: ~p"/users/api-tokens")}
  end

  @impl true
  def handle_event("delete", %{"id" => id, "hex" => hex} = _params, socket) do
    token = UserToken.find(id)
    :ok = Accounts.delete_api_token(token.token)

    socket =
      socket
      |> put_flash(:info, "token##{id} #{hex} deleted")

    {:noreply, stream_delete(socket, :api_tokens, token)}
  end

  @impl true
  def handle_event("delete-all", %{} = _params, socket) do
    current_user = socket.assigns.current_user
    query = Accounts.list_api_tokens_query(current_user, :all)
    Repo.delete_all(query)

    socket =
      socket
      |> put_flash(:info, "tokens all deleted")

    {:noreply, push_navigate(socket, to: ~p"/users/api-tokens")}
  end

  @impl true
  def handle_event("next-page", _, socket) do
    current_user = socket.assigns.current_user
    {:noreply, paginate_tokens(socket, current_user, socket.assigns.page + 1)}
  end

  @impl true
  def handle_event("prev-page", %{"_overran" => true}, socket) do
    current_user = socket.assigns.current_user
    {:noreply, paginate_tokens(socket, current_user, 1)}
  end

  @impl true
  def handle_event("prev-page", _, socket) do
    current_user = socket.assigns.current_user

    if socket.assigns.page > 1 do
      {:noreply, paginate_tokens(socket, current_user, socket.assigns.page - 1)}
    else
      {:noreply, socket}
    end
  end

  defp paginate_tokens(socket, user, new_page) when new_page >= 1 do
    %{
      page: cur_page,
      per_page: per_page
    } = socket.assigns

    tokens =
      Accounts.list_api_tokens(user, :all, page: new_page, per_page: per_page)

    {tokens, at, limit} =
      cond do
        new_page > cur_page ->
          {tokens, -1, per_page * 3 * -1}

        new_page == cur_page ->
          {tokens, 0, per_page * 3 * -1}

        true ->
          {tokens, 0, per_page * 3}
      end

    case tokens do
      [] ->
        socket
        |> assign(end_of_timeline: at == -1)
        # handle first blank page
        |> stream(:api_tokens, tokens, at: at, limit: limit)

      [_ | _] = tokens ->
        socket
        |> assign(end_of_timeline: false)
        |> assign(:page, new_page)
        |> stream(:api_tokens, tokens, at: at, limit: limit)
    end
  end
end
