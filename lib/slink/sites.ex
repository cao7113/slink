defmodule Slink.Sites do
  @moduledoc """
  The Sites context.
  """

  import Ecto.Query, warn: false
  alias Slink.Repo

  alias Slink.Sites.Site
  alias Slink.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any site changes.

  The broadcasted messages match the pattern:

    * {:created, %Site{}}
    * {:updated, %Site{}}
    * {:deleted, %Site{}}

  """
  def subscribe_sites(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Slink.PubSub, "user:#{key}:sites")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Slink.PubSub, "user:#{key}:sites", message)
  end

  @doc """
  Returns the list of sites.

  ## Examples

      iex> list_sites(scope)
      [%Site{}, ...]

  """
  def list_sites(%Scope{} = _scope) do
    # Repo.all_by(Site, user_id: scope.user.id)
    from(s in Site, order_by: [desc: s.updated_at], limit: 100)
    |> Repo.all()
  end

  @doc """
  Gets a single site.

  Raises `Ecto.NoResultsError` if the Site does not exist.

  ## Examples

      iex> get_site!(scope, 123)
      %Site{}

      iex> get_site!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_site!(%Scope{} = scope, id) do
    Repo.get_by!(Site, id: id, user_id: scope.user.id)
  end

  def get_by_url(url) do
    Repo.get_by(Site, url: url)
  end

  @doc """
  Creates a site.

  ## Examples

      iex> create_site(scope, %{field: value})
      {:ok, %Site{}}

      iex> create_site(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_site(%Scope{} = scope, attrs) do
    with {:ok, site = %Site{}} <-
           %Site{}
           |> Site.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, site})
      {:ok, site}
    end
  end

  @doc """
  Updates a site.

  ## Examples

      iex> update_site(scope, site, %{field: new_value})
      {:ok, %Site{}}

      iex> update_site(scope, site, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_site(%Scope{} = scope, %Site{} = site, attrs) do
    true = site.user_id == scope.user.id

    with {:ok, site = %Site{}} <-
           site
           |> Site.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, site})
      {:ok, site}
    end
  end

  @doc """
  Deletes a site.

  ## Examples

      iex> delete_site(scope, site)
      {:ok, %Site{}}

      iex> delete_site(scope, site)
      {:error, %Ecto.Changeset{}}

  """
  def delete_site(%Scope{} = scope, %Site{} = site) do
    true = site.user_id == scope.user.id

    with {:ok, site = %Site{}} <-
           Repo.delete(site) do
      broadcast(scope, {:deleted, site})
      {:ok, site}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking site changes.

  ## Examples

      iex> change_site(scope, site)
      %Ecto.Changeset{data: %Site{}}

  """
  def change_site(%Scope{} = scope, %Site{} = site, attrs \\ %{}) do
    true = site.user_id == scope.user.id

    Site.changeset(site, attrs, scope)
  end

  def get_site_url("http" <> _ = url) do
    [schema, rest] = String.split(url, "://", parts: 2)
    [host | _] = String.split(rest, "/", parts: 2)
    schema <> "://" <> host
  end

  @doc """
  Get site name from site-url
  """
  def get_site_name(site_url) do
    %URI{
      host: host,
      port: _port
    } = URI.parse(site_url)

    host
    |> String.replace("www.", "")
    |> String.replace(".com", "")
    |> String.replace(".", "-")
  end
end
