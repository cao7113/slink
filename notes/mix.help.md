mix                                   # Runs the default task (current: "mix run")
mix app.config                        # Configures all registered apps
mix app.start                         # Starts all registered apps
mix app.tree                          # Prints the application tree
mix archive                           # Lists installed archives
mix archive.build                     # Archives this project into a .ez file
mix archive.install                   # Installs an archive locally
mix archive.uninstall                 # Uninstalls archives
mix assets.build                      # Alias for tailwind slink, bun js
mix assets.clean                      # Alias for phx.digest.clean --all
mix assets.deploy                     # Alias for tailwind slink --minify, bun js --minify, phx.digest
mix assets.setup                      # Alias for tailwind.install --if-missing, bun.install --if-missing, bun assets install
mix bun                               # Invokes bun with the profile and args
mix bun.install                       # Installs bun under _build
mix clean                             # Deletes generated application files
mix cmd                               # Executes the given command
mix compile                           # Compiles source files
mix demo                              # Alias for demo.test, cmd mix demo.test
mix demo.test                         # Alias for &demo_task/1
mix deps                              # Lists dependencies and their status
mix deps.clean                        # Deletes the given dependencies' files
mix deps.compile                      # Compiles dependencies
mix deps.get                          # Fetches unavailable and out of date dependencies
mix deps.tree                         # Prints the dependency tree
mix deps.unlock                       # Unlocks the given dependencies
mix deps.update                       # Updates the given dependencies
mix dev.db.init                       # Alias for ecto.drop --force-drop, ecto.create
mix dev.init                          # Alias for run run/dev/seed.exs
mix dev.reset                         # Alias for ecto.reset.force, dev.init
mix do                                # Executes the tasks separated by plus
mix ecto                              # Prints Ecto help information
mix ecto.create                       # Creates the repository storage
mix ecto.drop                         # Drops the repository storage
mix ecto.dump                         # Dumps the repository database structure
mix ecto.gen.migration                # Generates a new migration for the repo
mix ecto.gen.repo                     # Generates a new repository
mix ecto.load                         # Loads previously dumped database structure
mix ecto.migrate                      # Runs the repository migrations
mix ecto.migrations                   # Displays the repository migration status
mix ecto.reset                        # Alias for ecto.drop, ecto.setup
mix ecto.reset.force                  # Alias for ecto.drop --force-drop, ecto.setup
mix ecto.rollback                     # Rolls back the repository migrations
mix ecto.setup                        # Alias for ecto.create, ecto.migrate, run priv/repo/seeds.exs
mix elixir_make.checksum              # Fetch precompiled NIFs and build the checksums
mix elixir_make.precompile            # Precompiles the given project for all targets
mix escript                           # Lists installed escripts
mix escript.build                     # Builds an escript for the project
mix escript.install                   # Installs an escript locally
mix escript.uninstall                 # Uninstalls escripts
mix eval                              # Evaluates the given code
mix expo.msgfmt                       # Generate binary message catalog from textual message description.
mix expo.msguniq                      # Unifies duplicate translations in message catalog
mix format                            # Formats the given files/patterns
mix gettext.extract                   # Extracts messages from source code
mix gettext.merge                     # Merge template files into message files
mix git_ops.check_message             # Check if a file's content follows the Conventional Commits spec
mix git_ops.install                   # Installs GitOps into a project.
mix git_ops.message_hook              # Enables automatic check if git commit message follows Conventional Commits spec
mix git_ops.project_info              # Return information about the project.
mix git_ops.release                   # Parses the commit log and writes any updates to the changelog
mix h                                 # List ehelper tasks
mix h.app.env                         # Show application env config, eg. mix h.app.env logger
mix h.chrome.mv3                      # Gen Chrome Extension V3 manifest.json
mix h.cookie                          # Gen random node cookie
mix h.dep                             # Show dep info from hex.pm
mix h.deps                            # Show project deps info friendly
mix h.deps.stat                       # Summarize local deps stats info managed by ehelper
mix h.docs                            # Common used docs tasks
mix h.fetch                           # Fetch url testing
mix h.fly                             # Gen fly.toml to deploy app to https://fly.io
mix h.gen.secret                      # Generates a secret
mix h.gh.ci                           # Gen github actions workflows for ci
mix h.git.ops.types                   # Show git_ops types
mix h.hi                              # Hello mix task
mix h.iex                             # Gen ./.iex.exs
mix h.iex.local                       # Gen ./.iex.local.exs
mix h.just                            # Gen Justfile as https://just.systems/man/en/
mix h.me                              # Gen README.md
mix h.prj                             # Show project config
mix h.repo.clone                      # Clone dep code into local repository _repos/
mix h.repos                           # Summarize local repos stats info managed by ehelper
mix h.secret                          # Gen random secret
mix h.taskfile                        # Gen Taskfile.yml
mix h.taskfile.mix                    # Gen Taskfile.yml for mix project
mix h.taskfile.phx                    # Gen Taskfile.yml for phx project
mix h.test                            # Just test task
mix help                              # Prints help information for tasks, aliases, modules, and applications
mix hex                               # Prints Hex help information
mix hex.audit                         # Shows retired Hex deps for the current project
mix hex.build                         # Builds a new package version locally
mix hex.config                        # Reads, updates or deletes local Hex config
mix hex.docs                          # Fetches or opens documentation of a package
mix hex.info                          # Prints Hex information
mix hex.organization                  # Manages Hex.pm organizations
mix hex.outdated                      # Shows outdated Hex deps for the current project
mix hex.owner                         # Manages Hex package ownership
mix hex.package                       # Fetches or diffs packages
mix hex.publish                       # Publishes a new package version
mix hex.registry                      # Manages local Hex registries
mix hex.repo                          # Manages Hex repositories
mix hex.retire                        # Retires a package version
mix hex.search                        # Open and perform searches
mix hex.sponsor                       # Show Hex packages accepting sponsorships
mix hex.user                          # Manages your Hex user account
mix igniter.add                       # Adds the provided deps to `mix.exs`
mix igniter.add_extension             # Adds an extension to your `.igniter.exs` configuration file.
mix igniter.apply_upgrades            # Applies the upgrade scripts for the list of package version changes provided.
mix igniter.gen.task                  # Generates a new igniter task
mix igniter.install                   # Install a package or packages, and run any associated installers.
mix igniter.move_files                # Moves any relevant files to their 'correct' location.
mix igniter.refactor.rename_function  # Rename functions across a project with automatic reference updates.
mix igniter.refactor.unless_to_if_not # Rewrites occurrences of `unless x` to `if !x` across the project.
mix igniter.remove                    # Removes the provided deps from `mix.exs`
mix igniter.setup                     # Creates or updates a .igniter.exs file, used to configure Igniter for end user's preferences.
mix igniter.update_gettext            # Applies changes to resolve a warning introduced in gettext 0.26.0
mix igniter.upgrade                   # Fetch and upgrade dependencies. A drop in replacement for `mix deps.update` that also runs upgrade tasks.
mix loadconfig                        # Loads and persists the given configuration
mix local                             # Lists tasks installed locally via archives
mix local.hex                         # Installs Hex locally
mix local.phx                         # Updates the Phoenix project generator locally
mix local.rebar                       # Installs Rebar locally
mix new                               # Creates a new Elixir project
mix nimble_parsec.compile             # Compiles a parser and injects its content into the parser file
mix phx                               # Prints Phoenix help information
mix phx.digest                        # Digests and compresses static files
mix phx.digest.clean                  # Removes old versions of static assets.
mix phx.gen                           # Lists all available Phoenix generators
mix phx.gen.auth                      # Generates authentication logic for a resource
mix phx.gen.cert                      # Generates a self-signed certificate for HTTPS testing
mix phx.gen.channel                   # Generates a Phoenix channel
mix phx.gen.context                   # Generates a context with functions around an Ecto schema
mix phx.gen.embedded                  # Generates an embedded Ecto schema file
mix phx.gen.html                      # Generates context and controller for an HTML resource
mix phx.gen.json                      # Generates context and controller for a JSON resource
mix phx.gen.live                      # Generates LiveView, templates, and context for a resource
mix phx.gen.notifier                  # Generates a notifier that delivers emails by default
mix phx.gen.presence                  # Generates a Presence tracker
mix phx.gen.release                   # Generates release files and optional Dockerfile for release-based deployments
mix phx.gen.schema                    # Generates an Ecto schema and migration file
mix phx.gen.secret                    # Generates a secret
mix phx.gen.socket                    # Generates a Phoenix socket handler
mix phx.new                           # Creates a new Phoenix v1.8.1 application
mix phx.new.ecto                      # Creates a new Ecto project within an umbrella project
mix phx.new.web                       # Creates a new Phoenix web project within an umbrella project
mix phx.routes                        # Prints all routes
mix phx.server                        # Starts applications and their servers
mix precommit                         # Alias for compile --warning-as-errors, deps.unlock --unused, format, test
mix profile.cprof                     # Profiles the given file or expression with cprof
mix profile.eprof                     # Profiles the given file or expression with eprof
mix profile.fprof                     # Profiles the given file or expression with fprof
mix profile.tprof                     # Profiles the given file or expression with tprof
mix release                           # Assembles a self-contained release
mix release.init                      # Generates sample files for releases
mix routes                            # Alias for phx.routes
mix run                               # Runs the current application
mix setup                             # Alias for deps.get, ecto.setup, assets.setup, assets.build
mix swoosh.mailbox.server             # Starts the mailbox preview server
mix tailwind                          # Invokes tailwind with the profile and args
mix tailwind.install                  # Installs Tailwind executable
mix test                              # Alias for ecto.create --quiet, ecto.migrate --quiet, test
mix test                              # Runs a project's tests
mix test.coverage                     # Build report from exported test coverage
mix test.reset                        # Alias for ecto.reset.force
mix xref                              # Prints cross reference information
iex -S mix                            # Starts IEx and runs the default task

Use "mix help <TASK>" for more information on a particular command.
