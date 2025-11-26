# Presence

- https://hexdocs.pm/phoenix/presence.html

```
$ mix phx.gen.presence
* creating lib/slink_web/channels/presence.ex

Add your new module to your supervision tree,
in lib/slink/application.ex:

    children = [
      ...
      SlinkWeb.Presence
    ]

You're all set! See the Phoenix.Presence docs for more details:
https://hexdocs.pm/phoenix/Phoenix.Presence.html
```

## Test

- many tabs open: http://localhost:4000/pages/chat