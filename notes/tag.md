# Tag

- https://hexdocs.pm/ecto/3.13.2/constraints-and-upserts.html
- https://hexdocs.pm/ecto/3.13.2/associations.html

## Link Tag with many-to-many

```
$ mix phx.gen.live --web admin Tags Tag tags name group
* creating lib/slink_web/live/admin/tag_live/show.ex
* creating lib/slink_web/live/admin/tag_live/index.ex
* creating lib/slink_web/live/admin/tag_live/form.ex
* creating test/slink_web/live/admin/tag_live_test.exs
* creating lib/slink/tags/tag.ex
* creating priv/repo/migrations/20250819094036_create_tags.exs
* creating lib/slink/tags.ex
* injecting lib/slink/tags.ex
* creating test/slink/tags_test.exs
* injecting test/slink/tags_test.exs
* creating test/support/fixtures/tags_fixtures.ex
* injecting test/support/fixtures/tags_fixtures.ex

Add the live routes to your Admin :browser scope in lib/slink_web/router.ex:

    scope "/admin", SlinkWeb.Admin do
      pipe_through :browser
      ...

      live "/tags", TagLive.Index, :index
      live "/tags/new", TagLive.Form, :new
      live "/tags/:id", TagLive.Show, :show
      live "/tags/:id/edit", TagLive.Form, :edit
    end

Ensure the routes are defined in a block that sets the `:current_scope` assign.

Remember to update your repository by running migrations:

    $ mix ecto.migrate
```

## LinkTag

```
mix phx.gen.schema Links.LinkTag link_tags link_id:references:links tag_id:references:tags
```
