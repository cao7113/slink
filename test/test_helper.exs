ExUnit.start()
ExUnit.configure(exclude: [external: true, try: true, manual: true])
Ecto.Adapters.SQL.Sandbox.mode(Slink.Repo, :manual)
