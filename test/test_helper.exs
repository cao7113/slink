ExUnit.start()
ExUnit.configure(exclude: [external: true, manual: true, try: true])
Ecto.Adapters.SQL.Sandbox.mode(Slink.Repo, :manual)
