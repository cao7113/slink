defmodule Mix.Tasks.Links.Dump do
  @moduledoc """
  Dump dev links from current database links
  """

  use Mix.Task

  alias Slink.Repo
  alias Slink.Links
  import Ecto.Query

  @requirements ["app.start"]
  @limit 20

  def run(_) do
    json =
      Repo.all(
        from l in Links.Link,
          order_by: [asc: l.id],
          limit: @limit
      )
      |> Enum.map(fn link ->
        link |> Map.from_struct() |> Map.take([:title, :url])
      end)
      |> Jason.encode!(pretty: true)

    file = "run/dev/links.json"
    File.write!(file, json)
    Mix.shell().info("Dumped links to file: #{file}")
  end
end
