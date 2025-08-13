# Links design and pages

## Models

links table
- title
- url
- user_id: as contributor

unique url

link_usages table
- title
- link_id
- user_id
- note
- favor_at
- last_visit_at
- total_visit_times
- tags array

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

## Link usages for link visitor

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

## Links in Admin

- admin
