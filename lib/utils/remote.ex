defmodule Remote do
  @moduledoc """
  Remote ops within a cluster

  Node info https://hexdocs.pm/elixir/1.18.4/Node.html#spawn/2
  erpc https://www.erlang.org/doc/apps/kernel/erpc.html
  """

  alias Slink.Links
  alias Slink.Links.Link

  require Logger

  @doc """
  Get node info
  """
  def info() do
    %{
      node: node(),
      alive: Node.alive?(),
      cookie: Node.get_cookie(),
      list: Node.list(),
      connected: Node.list(:connected),
      hidden: Node.list(:hidden)
    }
  end

  @doc """
  Test rpc call with remote node
  """
  def rpc_test(node \\ first_remote_node() || node()) do
    :erpc.call(node, Node, :self, [])
  end

  @doc """
  Find first remote node begin with prefix

  ## Examples
    [:"slink-01K0ZHJ4MVRWSR4GMDY5S4VMK4@fdaa:2:686c:a7b:fc:cf02:d919:2"]
    -> :"slink-01K0ZHJ4MVRWSR4GMDY5S4VMK4@fdaa:2:686c:a7b:fc:cf02:d919:2"
  """
  def first_remote_node(prefix \\ "slink") do
    :connected
    |> Node.list()
    |> Enum.find(fn atom_name ->
      String.starts_with?(atom_name |> to_string(), prefix)
    end)
  end

  def add_new_node(node, cookie \\ Node.get_cookie()) when is_atom(node) and is_atom(cookie) do
    Node.set_cookie(cookie)
    Node.connect(node)
    # Node.list(:connected)
  end

  ## Links

  def fetch_remote_links(node \\ first_remote_node()) do
    :erpc.call(node, Slink.Links.Link, :all, [[order_by: [asc: :id]]])
  end

  def save_remote_links_as!(
        file \\ "./_local/remote-data/links-#{DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_string() |> String.replace(" ", "T")}.json",
        node \\ first_remote_node()
      ) do
    links =
      fetch_remote_links(node)
      |> Enum.map(fn link ->
        link |> Map.from_struct() |> Map.delete(:__meta__)
      end)

    file = Path.expand(file)
    dir = Path.dirname(file)
    File.mkdir_p!(dir)
    File.write!(file, Jason.encode!(links, pretty: true))
    IO.puts("Saved remote links to #{file}")
  end

  def download_remote_links!(node \\ first_remote_node()) do
    handler = fn items ->
      items
      |> Enum.with_index(fn link, idx ->
        Logger.info("downloading [#{idx}] id=#{link.id} #{link.url}")
        attrs = Link.get_new_attrs(link)

        with cs <- Link.new_changeset(attrs),
             {:ok, new_link} <- Slink.Repo.insert(cs) do
          Logger.info("created local link #{new_link.id}")
        else
          {:error, %Ecto.Changeset{errors: errors}} ->
            Logger.warning("failed to create local link: #{inspect(errors)}")

          err ->
            Logger.error("failed to create local link: #{inspect(err)}")
        end
      end)
    end

    Links.batch_run_with_cursor(node: node, handler: handler)
  end

  def upload_remote_links!(node, links) when is_list(links) do
    links
    |> Enum.with_index(fn link, idx ->
      Logger.info("uploading [#{idx}] id=#{link.id} #{link.url}")

      :erpc.call(node, Slink.Links.Link, :find_by, [[url: link.url]])
      |> case do
        nil ->
          attrs = Link.get_new_attrs(link)
          new_link = :erpc.call(node, Slink.Links.Link, :create!, [attrs])
          Logger.info("created remote link #{new_link.id}")

        found ->
          Logger.info("already existed link: #{found.id} with url: #{link.url}")
      end
    end)
  end
end
