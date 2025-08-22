# Links design and pages

## Link Model

links table
- title
- url
- user_id: as contributor

unique_index on url

## Public links show

list links with possible scope

build to my-link actions:
- favor
- add note
- read later?

```
$ mix phx.gen.live Links Link links --no-context title url user_id:integer
* creating lib/slink_web/live/link_live/show.ex
* creating lib/slink_web/live/link_live/index.ex
* creating lib/slink_web/live/link_live/form.ex
* creating test/slink_web/live/link_live_test.exs

Add the live routes to your browser scope in lib/slink_web/router.ex:

    live "/links", LinkLive.Index, :index
    live "/links/new", LinkLive.Form, :new
    live "/links/:id", LinkLive.Show, :show
    live "/links/:id/edit", LinkLive.Form, :edit

Ensure the routes are defined in a block that sets the `:current_scope` assign.
```

## My links

actions:
- CRUD

```
$ mix phx.gen.live Links Link links --web my --no-context title url user_id:integer
* creating lib/slink_web/live/my/link_live/show.ex
* creating lib/slink_web/live/my/link_live/index.ex
* creating lib/slink_web/live/my/link_live/form.ex
* creating test/slink_web/live/my/link_live_test.exs

Add the live routes to your My :browser scope in lib/slink_web/router.ex:

    scope "/my", SlinkWeb.My do
      pipe_through :browser
      ...

      live "/links", LinkLive.Index, :index
      live "/links/new", LinkLive.Form, :new
      live "/links/:id", LinkLive.Show, :show
      live "/links/:id/edit", LinkLive.Form, :edit
    end

Ensure the routes are defined in a block that sets the `:current_scope` assign.
```

## UserLink

user_links table
- title
- link_id
- user_id
- note
- favor_at
- last_visit_at
- total_visit_times


```
$ mix phx.gen.live --web my UserLink user_links link_id:references:links title note:text favor_at:utc_datetime last_visit_at:utc_datetime total_visit_times:integer
* creating lib/slink_web/live/my/user_link_live/show.ex
* creating lib/slink_web/live/my/user_link_live/index.ex
* creating lib/slink_web/live/my/user_link_live/form.ex
* creating test/slink_web/live/my/user_link_live_test.exs
* creating lib/slink/user_links/user_link.ex
* creating priv/repo/migrations/20250815004721_create_user_links.exs
* creating lib/slink/user_links.ex
* injecting lib/slink/user_links.ex
* creating test/slink/user_links_test.exs
* injecting test/slink/user_links_test.exs
* creating test/support/fixtures/user_links_fixtures.ex
* injecting test/support/fixtures/user_links_fixtures.ex

Add the live routes to your My :browser scope in lib/slink_web/router.ex:

    scope "/my", SlinkWeb.My do
      pipe_through :browser
      ...

      live "/user_links", UserLinkLive.Index, :index
      live "/user_links/new", UserLinkLive.Form, :new
      live "/user_links/:id", UserLinkLive.Show, :show
      live "/user_links/:id/edit", UserLinkLive.Form, :edit
    end

Ensure the routes are defined in a block that sets the `:current_scope` assign.

Remember to update your repository by running migrations:

    $ mix ecto.migrate
```

## Link Logs

```
mix phx.gen.shcema Links.LinkLog link_logs link_id:references:links event:string # user_id:references:users
```

## Tags

tags table
- name

link_tags table
- link_id
- tag_id

## Link Site

sites table
- name
- url
- intro
- logo_url
- category

```
$ mix phx.gen.live --web admin Site sites name url logo_url category intro:text
* creating lib/slink_web/live/admin/site_live/show.ex
* creating lib/slink_web/live/admin/site_live/index.ex
* creating lib/slink_web/live/admin/site_live/form.ex
* creating test/slink_web/live/admin/site_live_test.exs
* creating lib/slink/sites/site.ex
* creating priv/repo/migrations/20250822073358_create_sites.exs
* creating lib/slink/sites.ex
* injecting lib/slink/sites.ex
* creating test/slink/sites_test.exs
* injecting test/slink/sites_test.exs
* creating test/support/fixtures/sites_fixtures.ex
* injecting test/support/fixtures/sites_fixtures.ex

Add the live routes to your Admin :browser scope in lib/slink_web/router.ex:

    scope "/admin", SlinkWeb.Admin do
      pipe_through :browser
      ...

      live "/sites", SiteLive.Index, :index
      live "/sites/new", SiteLive.Form, :new
      live "/sites/:id", SiteLive.Show, :show
      live "/sites/:id/edit", SiteLive.Form, :edit
    end


Remember to update your repository by running migrations:

    $ mix ecto.migrate
```
