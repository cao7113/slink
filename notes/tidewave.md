# Tidewave ai

- https://hexdocs.pm/tidewave/mcp.html

## Uage

```
execute_sql_query
// not work now??
select 1;
```

## Configure IDE

```
{
  /// The name of your MCP server
  "tidewave-mcp-server": {
    /// The command which runs the MCP server
    "command": "/Users/rj/dev/elab/mcp-proxy",
    /// The arguments to pass to the MCP server
    "args": ["http://localhost:4000/tidewave/mcp"],
    /// The environment variables to set
    "env": {}
  }
}
```

## Install tidewave for phoenix

```
$ mix igniter.install tidewave
compile ✔

Update: mix.exs

       ...|
 37  37   |  defp deps do
 38  38   |    [
     39 + |      {:tidewave, "~> 0.3", only: [:dev]},
 39  40   |      {:bcrypt_elixir, "~> 3.0"},
 40  41   |      {:phoenix, "~> 1.8.0", override: true},
       ...|


Modify mix.exs and install? [Y/n] y
compiling tidewave ✔
`tidewave.install` ✔

The following installer was found and executed: `tidewave.install`:

Update: lib/slink_web/endpoint.ex

     ...|
27 27   |    only: SlinkWeb.static_paths()
28 28   |
   29 + |  if Code.ensure_loaded?(Tidewave) do
   30 + |    plug Tidewave
   31 + |  end
   32 + |
29 33   |  # Code reloading can be explicitly enabled under the
30 34   |  # :code_reloader configuration of your endpoint.
     ...|


Proceed with changes? [Y/n] y

Notices:

* Tidewave next steps:

  * Enable Tidewave in your editor: https://hexdocs.pm/tidewave/mcp.html


Notices were printed above. Please read them all before continuing!
```
