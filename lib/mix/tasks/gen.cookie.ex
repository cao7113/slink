defmodule Mix.Tasks.Gen.Cookie do
  use Mix.Task

  def run(_) do
    40
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> IO.inspect(label: "Generated cookie")
  end
end
