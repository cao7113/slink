#!/usr/bin/env elixir

# NOTE: ensure fly wireguard is on!

db_url = System.fetch_env!("FLY_DB_URL")

%URI{
  scheme: "postgres",
  userinfo: userinfo,
  host: dbhost,
  # port: 5432,
  # path: "/db",
  path: "/" <> dbname
  # query: "sslmode=disable"
} = URI.parse(db_url)

[username, password] = String.split(userinfo, ":")
tm = DateTime.utc_now(:second) |> DateTime.to_iso8601() |> String.replace(~r/[^\d]/, "")
dump_file = "_local/dump/flydb/#{dbname}-bak-#{tm}.sql"
db_dir = Path.dirname(dump_file)
File.mkdir_p!(db_dir)

dump_cmd =
  "PGPASSWORD='#{password}' pg_dump -h #{dbhost} -p 5432 -U #{username} -Fc -b -vv -f #{dump_file} -d #{dbname}"

IO.puts("# run dump command manually: \n#{dump_cmd}")
IO.puts("")

System.cmd("bash", ["-c", dump_cmd])
