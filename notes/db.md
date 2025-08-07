# DB ops

## Reset sequence last-value

```
SELECT setval('links_id_seq', COALESCE((SELECT MAX(id) FROM links), 0));
SELECT * FROM pg_sequences WHERE sequencename = 'links_id_seq';
```

## connections

```
# get pg version
select version();
# get all connections
SELECT * FROM pg_stat_activity WHERE datname = 'slink';
# terminate all connections
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'slink'; AND pid <> pg_backend_pid();
# force drop db since pg13+
DROP DATABASE slink WITH (FORCE);
```

## Rename db

```
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'slink_v2';
ALTER DATABASE slink_v2 RENAME TO slink;
```
