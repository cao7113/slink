# Admin

## User

```
$ mix phx.gen.live --web admin Accounts User users --no-context email name site confirmed_at:utc_datetime admin_role inserted_at:utc_datetime updated_at:utc_datetime
* creating lib/slink_web/live/admin/user_live/show.ex
* creating lib/slink_web/live/admin/user_live/index.ex
* creating lib/slink_web/live/admin/user_live/form.ex
* creating test/slink_web/live/admin/user_live_test.exs

Add the live routes to your Admin :browser scope in lib/slink_web/router.ex:

    scope "/admin", SlinkWeb.Admin do
      pipe_through :browser
      ...

      live "/users", UserLive.Index, :index
      live "/users/new", UserLive.Form, :new
      live "/users/:id", UserLive.Show, :show
      live "/users/:id/edit", UserLive.Form, :edit
    end

Ensure the routes are defined in a block that sets the `:current_scope` assign.
```
