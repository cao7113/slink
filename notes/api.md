# API

## API Prefix

- https://hexdocs.pm/phoenix/1.8.0/Mix.Tasks.Phx.Gen.Json.html#module-api-prefix

```
config :slink,
  generators: [
    # this is default api route prefix
    # api_prefix: "/api",
    api_prefix: ""
  ]

# Prefer api controller like below:
mix phx.gen.json Links Link links title url --web api # --no-context
# Auto place controllers into lib/*_web/controllers/api/*_controller.ex
```

## Links API

https://hexdocs.pm/phoenix/1.8.0/Mix.Tasks.Phx.Gen.Json.html

```
mix phx.gen.json Links Link links title url # user_id:integer

Notes:
- user_id field: auto added because default scope is user???!
- --web api    : cause error api path

Add the resource to your Api :api scope in lib/slink_web/router.ex:

    scope "/api", SlinkWeb.Api do
      pipe_through :api
      ...
      resources "/links", LinkController
    end

Ensure the routes are defined in a block that sets the `:current_scope` assign.

Remember to update your repository by running migrations:

    $ mix ecto.migrate
```

## API token

https://hexdocs.pm/phoenix/1.8.0/api_authentication.html#adding-api-functions-to-the-context

```
user = User.find(1)
api_token = Accounts.create_user_api_token(user)
{:ok, fetched_user} = Accounts.fetch_user_by_api_token(api_token)
user === fetched_user
```
