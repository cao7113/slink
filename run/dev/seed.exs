#! mix run

alias Slink.Accounts
alias Slink.Accounts.UserToken
alias Slink.Links

email = "a1@b.c"
password = "123456123456"
api_token = "dev_api_token---kC6IkpcQRO4VvuVFgszZRnvDDSU"

# json data from: mix links.dump
links =
  Path.join(__DIR__, "links.json")
  |> File.read!()
  |> Jason.decode!()

info = %{
  email: email,
  password: password,
  api_token: api_token
}

user = Accounts.get_user_by_email(email)

dev_user =
  if !user do
    # register user
    {:ok, user} = Accounts.register_user(%{email: email})

    # confirm user email by magic link
    magic_token = Accounts.get_login_magic_link_token(user)
    Accounts.login_user_by_magic_link(magic_token)

    # set password
    {:ok, {new_user, _}} = Accounts.update_user_password(user, %{password: password})
    # true = User.valid_password?(new_user, password)

    # create api-token
    api_token
    |> Accounts.fetch_user_by_api_token()
    |> case do
      {:ok, got_user} ->
        if got_user.id != user.id do
          raise "Mismatch user-id #{got_user.id} != #{user.id}"
        end

      :error ->
        secret = api_token |> UserToken.decode_secret_token!()
        Accounts.create_user_api_token_with_secret(user, secret)
    end

    new_user
  else
    user
  end

IO.puts("dev-user=#{dev_user.id} created with info #{info |> inspect(pretty: true)}!")

user_scope = Accounts.Scope.for_user(dev_user)

## Links

links
|> Enum.each(fn link ->
  Links.create_link(user_scope, link)
end)

IO.puts("#{Enum.count(links)} links created!")
