#!/usr/bin/env elixir

db_dir = "_local/dump/flydb"
target_db = "slink_dev"

last_file = db_dir |> File.ls!() |> Enum.sort(:desc) |> List.first()
db_file_path = Path.join(db_dir, last_file)

restore_cmd = "pg_restore -v -h localhost -U postgres -j 2 -d #{target_db} #{db_file_path}"
IO.puts("# run restore command(should first create target db):")
IO.puts("create database #{target_db};")
IO.puts(restore_cmd)

System.cmd("bash", ["-c", restore_cmd])
