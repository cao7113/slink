defmodule Slink.Repo do
  use Ecto.Repo,
    otp_app: :slink,
    adapter: Ecto.Adapters.Postgres
end
