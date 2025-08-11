#! mix run
alias Slink.Repo

%{
  username: username,
  database: dbname,
  hostname: dbhost,
  password: password
} = Repo.config() |> Keyword.take([:username, :password, :hostname, :database]) |> Map.new()

tm = DateTime.utc_now(:second) |> DateTime.to_iso8601() |> String.replace(~r/[^\d]/, "")

dump_file = "_local/dump/#{dbname}-bak-#{tm}.sql"
File.mkdir_p!(Path.dirname(dump_file))

dump_cmd =
  "PGPASSWORD='#{password}' pg_dump -h #{dbhost} -p 5432 -U #{username} -Fc -b -v -f #{dump_file} -d #{dbname}"

IO.puts("# dump command: \n#{dump_cmd}")

target_db = "#{dbname}_#{tm}"
restore_cmd = "pg_restore -v -h localhost -U postgres -j 2 -d #{target_db} #{dump_file}"
IO.puts("# restore command(should first create target db):")
IO.puts("create database #{target_db};")
IO.puts(restore_cmd)
