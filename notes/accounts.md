# Accounts & User

## UserToken context

- login to
  - confirm # reset all user tokens
  - email magic-link
- session # after login
- change:*
- api-token for api access

## My Token

```
$ mix phx.gen.live Accounts UserToken user_tokens --web my --no-context context token user_id:integer
* creating lib/slink_web/live/my/user_token_live/show.ex
* creating lib/slink_web/live/my/user_token_live/index.ex
* creating lib/slink_web/live/my/user_token_live/form.ex
* creating test/slink_web/live/my/user_token_live_test.exs

Add the live routes to your My :browser scope in lib/slink_web/router.ex:

    scope "/my", SlinkWeb.My do
      pipe_through :browser
      ...

      live "/user_tokens", UserTokenLive.Index, :index
      live "/user_tokens/new", UserTokenLive.Form, :new
      live "/user_tokens/:id", UserTokenLive.Show, :show
      live "/user_tokens/:id/edit", UserTokenLive.Form, :edit
    end

Ensure the routes are defined in a block that sets the `:current_scope` assign.
```
