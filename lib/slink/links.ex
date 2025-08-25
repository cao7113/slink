defmodule Slink.Links do
  @moduledoc """
  The Links context.
  """

  import Ecto.Query, warn: false
  alias Slink.Repo

  alias Slink.Accounts.Scope
  alias Slink.Links.Link
  alias Slink.Links.UserLink
  alias Slink.Links.LinkLog
  alias Slink.Tags
  alias Slink.Links.LinkTag
  alias Slink.Sites

  require Logger

  @default_per_page 20
  @default_batch_size 200

  @doc """
  Subscribes to scoped notifications about any link changes.

  The broadcasted messages match the pattern:

    * {:created, %Link{}}
    * {:updated, %Link{}}
    * {:deleted, %Link{}}

  """
  def subscribe_links(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Slink.PubSub, "user:#{key}:links")
  end

  def subscribe_links(nil) do
    # nothing to subscribe
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Slink.PubSub, "user:#{key}:links", message)
  end

  @doc """
  Returns the list of links.

  ## Examples

      iex> list_links(scope)
      [%Link{}, ...]

  """
  # def list_links(%Scope{} = scope) do
  def list_links(_scope) do
    Link
    # |> where(user_id: ^scope.user.id)
    |> order_by(desc: :updated_at)
    |> limit(@default_per_page)
    |> Repo.all()
  end

  ## Search logic

  def search_links_count(nil), do: search_links_count("")

  def search_links_count(query) when is_binary(query) do
    build_search_query(query)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Search links by url or title
  """
  def search_links(socket, query, opts \\ [])
  def search_links(socket, nil, opts), do: search_links(socket, "", opts)

  def search_links(socket, query, opts) when is_binary(query) do
    query = query |> String.trim()

    do_search_links(socket, query, opts)
    |> Enum.with_index(fn link, idx ->
      %{link | list_index: idx + 1}
    end)
  end

  def do_search_links(socket, query, opts \\ []) when is_binary(query) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, @default_per_page)
    offset = (page - 1) * per_page

    build_search_query(socket, query)
    |> offset(^offset)
    |> limit(^per_page)
    |> Repo.all()
  end

  def build_search_query(socket, "") do
    scope = socket.assigns.current_scope

    if scope do
      from(l in Link,
        left_join: ul in UserLink,
        on: l.id == ul.link_id and ul.user_id == ^scope.user.id,
        order_by: [desc_nulls_last: ul.last_visit_at, desc: l.updated_at, desc: l.id],
        select: %{l | my_ulink: ul},
        preload: [:tags, :user]
      )
    else
      build_search_query("")
    end
  end

  def build_search_query(socket, query) when is_binary(query) do
    scope = socket.assigns.current_scope

    if scope do
      from(l in Link,
        left_join: ul in UserLink,
        on: l.id == ul.link_id and ul.user_id == ^scope.user.id,
        where: ilike(l.title, ^"%#{query}%") or ilike(l.url, ^"%#{query}%"),
        order_by: [desc_nulls_last: ul.last_visit_at, desc: l.updated_at, desc: l.id],
        select: %{l | my_ulink: ul},
        preload: [:tags, :user]
      )
    else
      build_search_query(query)
    end
  end

  def build_search_query("") do
    from(l in Link,
      order_by: [desc: l.updated_at, desc: l.id],
      preload: [:tags, :user]
    )
  end

  def build_search_query(query) when is_binary(query) do
    from(l in Link,
      where: ilike(l.title, ^"%#{query}%") or ilike(l.url, ^"%#{query}%"),
      order_by: [desc: l.updated_at, desc: l.id],
      preload: [:tags, :user]
    )
  end

  @doc """
  Gets a single link.

  Raises `Ecto.NoResultsError` if the Link does not exist.

  ## Examples

      iex> get_link!(123)
      %Link{}

      iex> get_link!(456)
      ** (Ecto.NoResultsError)

  """

  def get_link!(%Scope{} = scope, id) do
    Repo.get_by!(Link, id: id, user_id: scope.user.id)
  end

  def get_link!(_, id) do
    Repo.get_by!(Link, id: id)
  end

  def get_link!(id), do: get_link!(nil, id)

  def get_link_with_tags!(id) do
    Repo.get_by!(Link, id: id)
    |> Repo.preload(:tags)

    # from(l in Link, where: l.id == ^id, preload: [:tags])
    # |> Repo.one()
  end

  def get_link_with_resources(link_id) do
    Repo.get_by!(Link, id: link_id)
    |> Repo.preload([:user, :tags])
  end

  def get_or_create_link(%Scope{} = scope, %{url: url, title: _title} = attrs) do
    Repo.get_by(Link, url: url)
    |> case do
      %Link{} = link -> {:ok, link}
      nil -> create_link(scope, attrs)
    end
  end

  @doc """
  Creates a link.

  ## Examples

      iex> create_link(%{field: value})
      {:ok, %Link{}}

      iex> create_link(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_link(%Scope{} = scope, attrs) do
    with {:ok, link = %Link{}} <-
           %Link{}
           |> Link.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, link})
      # todo use pubsub to split concern
      fill_site(scope, link)
    end
  end

  @doc """
  Updates a link.

  ## Examples

      iex> update_link(link, %{field: new_value})
      {:ok, %Link{}}

      iex> update_link(link, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_link(%Scope{} = scope, %Link{} = link, attrs) do
    true = link.user_id == scope.user.id

    with {:ok, link = %Link{}} <-
           link
           |> Link.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, link})
      {:ok, link}
    end
  end

  @doc """
  Deletes a link.

  ## Examples

      iex> delete_link(link)
      {:ok, %Link{}}

      iex> delete_link(link)
      {:error, %Ecto.Changeset{}}

  """
  def delete_link(%Scope{} = scope, %Link{} = link) do
    true = link.user_id == scope.user.id

    with {:ok, link = %Link{}} <-
           Repo.delete(link) do
      broadcast(scope, {:deleted, link})
      {:ok, link}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking link changes.

  ## Examples

      iex> change_link(link)
      %Ecto.Changeset{data: %Link{}}

  """
  def change_link(%Scope{} = scope, %Link{} = link, attrs \\ %{}) do
    true = link.user_id == scope.user.id

    Link.changeset(link, attrs, scope)
  end

  ## Flop helpers

  @doc """
  Cursor-based run handler in batch https://hexdocs.pm/flop/Flop.html#module-pagination
  Prefer this when in large datasets using forward (first/after)

  Options:
  - first: 200
  - after: nil
  - handler: fn _ -> nil end
  - node: nil, remote node
  """
  def batch_run_with_cursor(opts \\ []) do
    flop = %Flop{
      first: Keyword.get(opts, :first, @default_batch_size),
      after: Keyword.get(opts, :after, nil),
      order_by: [:id],
      order_directions: [:asc]
    }

    handler =
      Keyword.get(opts, :handler, fn items ->
        Enum.map(items, & &1.id) |> Enum.join(",") |> IO.puts()
      end)

    node = Keyword.get(opts, :node)

    do_flop_run(node, Link, flop, for: Link)
    |> do_batch_run_with_cursor(handler, flop, node)
  end

  defp do_batch_run_with_cursor(run_resp, handler, flop, node)

  defp do_batch_run_with_cursor({result, %{has_next_page?: false} = _meta}, handler, _flop, _node) do
    handler.(result)
  end

  defp do_batch_run_with_cursor(
         {result, %{end_cursor: end_cursor, has_next_page?: true} = _meta},
         handler,
         flop,
         node
       ) do
    handler.(result)
    next_flop = flop |> Map.put(:after, end_cursor)
    next_resp = do_flop_run(node, Link, next_flop, for: Link)
    do_batch_run_with_cursor(next_resp, handler, next_flop, node)
  end

  defp do_flop_run(nil, query, flop, opts) do
    Flop.run(query, flop, opts)
  end

  # support remote call
  defp do_flop_run(node, query, flop, opts) do
    :erpc.call(node, Flop, :run, [query, flop, opts], 10000)
  end

  @doc """
  Page-based run handler in batch https://hexdocs.pm/flop/Flop.html#module-pagination
  NOTE: always triger total-count query in each batch
  """
  def batch_run_with_paged(opts \\ []) do
    flop = %Flop{
      page: Keyword.get(opts, :page, 1),
      page_size: Keyword.get(opts, :page_size, @default_batch_size),
      order_by: [:id],
      order_directions: [:asc]
    }

    handler =
      Keyword.get(opts, :handler, fn items ->
        Enum.map(items, & &1.id) |> Enum.join(",") |> IO.puts()
      end)

    Flop.run(Link, flop, for: Link)
    |> do_batch_run_with_paged(handler, flop)
  end

  defp do_batch_run_with_paged(run_resp, handler, flop)

  defp do_batch_run_with_paged({result, %{has_next_page?: false} = _meta}, handler, _flop) do
    handler.(result)
  end

  defp do_batch_run_with_paged(
         {result, %{next_page: next_page, has_next_page?: true} = _meta},
         handler,
         flop
       ) do
    handler.(result)
    next_flop = %{flop | page: next_page}
    next_resp = Flop.run(Link, next_flop, for: Link)
    do_batch_run_with_paged(next_resp, handler, next_flop)
  end

  ## Link logs

  @doc """
  Creates a link_log.

  ## Examples

      iex> create_link_log(scope, %{field: value})
      {:ok, %LinkLog{}}

      iex> create_link_log(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_link_log(scope, attrs) do
    with {:ok, link_log = %LinkLog{}} <-
           %LinkLog{}
           |> LinkLog.changeset(attrs, scope)
           |> Repo.insert() do
      # broadcast(scope, {:created, link_log})
      {:ok, link_log}
    end
  end

  def create_link_tag(scope, attrs) do
    with {:ok, link_tag = %LinkTag{}} <-
           %LinkTag{}
           |> LinkTag.changeset(attrs, scope)
           |> Repo.insert() do
      # broadcast(scope, {:created, link_tag})
      {:ok, link_tag}
    end
  end

  ## Tag related helpers

  def list_links_by_tag(%Scope{} = _scope, tag_name, limit \\ @default_per_page) do
    query =
      from(l in Link,
        join: t in assoc(l, :tags),
        where: t.name == ^tag_name,
        preload: [:tags, :user],
        limit: ^limit
      )

    query |> Repo.all()
  end

  # hot tags in links todo
  def hot_tags(limit \\ 10) do
    query =
      from(l in Link,
        join: t in assoc(l, :tags),
        group_by: t.name,
        order_by: [desc: count(t.id)],
        limit: ^limit,
        select: %{name: t.name, count: count(t.id)}
      )

    query |> Repo.all()
  end

  def tags_of(%Link{} = link) do
    %{tags: tags} = link |> Repo.preload(:tags)
    tags
  end

  def tags_string_of(%Link{} = link) do
    link |> tags_of |> Tags.tags_string()
  end

  def add_tag(%Link{} = link, tag_name, %Scope{} = scope) do
    with {:ok, tag} <- Tags.get_or_create_tag(scope, tag_name) do
      attrs = %{link_id: link.id, tag_id: tag.id}
      create_link_tag(scope, attrs)
    end
  end

  def remove_tag(%Link{id: link_id}, tag_name) do
    if tag = Tags.get_by_name(tag_name) do
      from(lt in LinkTag, where: lt.link_id == ^link_id and lt.tag_id == ^tag.id)
      |> Repo.delete_all()
    end
  end

  ## Site

  # hot sites in links todo
  def hot_sites(limit \\ 10) do
    query =
      from(l in Link,
        join: s in assoc(l, :site),
        group_by: s.name,
        order_by: [desc: count(s.id)],
        limit: ^limit,
        select: %{name: s.name, count: count(s.id)}
      )

    query |> Repo.all()
  end

  def fill_sites(%Scope{} = scope) do
    from(l in Link, where: is_nil(l.site_id), order_by: [desc: l.id])
    |> Repo.all()
    |> Enum.each(&fill_site(scope, &1))
  end

  def fill_site(%Scope{} = scope, %Link{url: url, site_id: nil} = link) do
    site_url = Sites.get_site_url(url)
    site = Sites.get_by_url(site_url)

    site =
      if site do
        site
      else
        site_name = Sites.get_site_name(site_url)

        {:ok, site} =
          Sites.create_site(scope, %{url: site_url, name: site_name})

        site
      end

    update_link(scope, link, %{site_id: site.id})
  end

  def fill_site(_, link), do: {:ok, link}
end
