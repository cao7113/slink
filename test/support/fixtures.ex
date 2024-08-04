defmodule Slink.Fixtures do
  @moduledoc """
  This module defines common test helpers for creating
  entities.
  """

  alias Slink.Accounts

  @doc """
  Batch gen specified fixtures
  """
  def batch_gen(gen_fun \\ &Slink.LinksFixtures.link_fixture/0, n \\ Enum.random(1..10))
      when is_function(gen_fun, 0) do
    Enum.each(1..n, fn _ -> gen_fun.() end)
  end

  def init_data!(pwd \\ "123456123456") do
    mark_email = "a1@b.c"

    if Accounts.User.exists?(email: mark_email) do
      raise "Already inited!"
    end

    users =
      1..3
      |> Enum.map(fn i ->
        email = "a#{i}@b.c"
        {:ok, user} = Accounts.register_user(%{email: email, password: pwd})
        IO.puts("create user##{user.id} email: #{email} with api-token")
        user
      end)

    adms =
      1..3
      |> Enum.map(fn i ->
        email = "adm#{i}@b.c"
        {:ok, user} = Accounts.register_user(%{email: email, password: pwd})
        Accounts.create_admin_from_user(user, role: :super)
        IO.puts("create admin-user##{user.id} email: #{email}")
        user
      end)

    [hd(users), hd(adms)]
    |> Enum.each(fn user ->
      # create api-tokens
      token = Accounts.create_user_api_token(user)

      append_file(".env.dev.api-token", """
      # #{user.email} id=#{user.id} api token generated at #{DateTime.utc_now()}
      USER#{user.id}_API_TOKEN=#{token}

      """)

      # links
      batch_gen(
        fn ->
          Slink.LinksFixtures.link_fixture(user_id: user.id)
        end,
        20
      )
    end)
  end

  def append_file(file_path, content) do
    File.open(file_path, [:append], fn file ->
      IO.binwrite(file, content)
    end)
  end
end
