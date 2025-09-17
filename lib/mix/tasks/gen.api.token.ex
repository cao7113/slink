defmodule Mix.Tasks.Gen.Api.Token do
  @moduledoc """
  Gen dev api-token
  """

  use Mix.Task
  alias Slink.Accounts.UserToken

  @switches [
    prefix: :string
  ]

  @default_prefix "dev_api_token---"

  def run(args) do
    {opts, _parsed, _invalid} = OptionParser.parse(args, switches: @switches)
    prefix = Keyword.get(opts, :prefix, @default_prefix)

    prefix_bytes = UserToken.decode_secret_token!(prefix)
    rand_bytes = :crypto.strong_rand_bytes(UserToken.secret_rand_size() - byte_size(prefix_bytes))

    (prefix_bytes <> rand_bytes)
    |> UserToken.encode_secret_token!()
    |> IO.inspect(label: "API token")
  end
end
