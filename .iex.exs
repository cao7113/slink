alias Slink, as: S
alias Slink.Repo
alias Slink.Mailer

# Accounts & User
alias Slink.Accounts
alias Slink.Accounts, as: A
alias Slink.Accounts.User
alias Slink.Accounts.User, as: U
alias Slink.Accounts.UserToken, as: Ut
alias Slink.Accounts.UserNotifier
alias Slink.Accounts.Scope
alias Slink.Accounts.Scope, as: Sc

## Links
alias Slink.Links
alias Slink.Links.Link
alias Slink.Links.UserLink
alias Slink.Links.UserLink, as: Ulink
alias Slink.Links.LinkLog
alias Slink.UserLinks
alias Slink.UserLinks, as: Ulinks
alias Slink.Tags
alias Slink.Tags.Tag
alias Slink.Sites
alias Slink.Sites.Site

# Web
alias SlinkWeb, as: Web
alias SlinkWeb.UserAuth
# Ep.config(:http), Ep.struct_url(), Ep.url()
alias SlinkWeb.Endpoint, as: Ep

## Remote
alias Remote, as: R
alias EnvHelper, as: Env
alias Builder, as: B

## Testing
alias Slink.Factory
alias Slink.Factory, as: F

## Helpers
alias SchemaMigration, as: Mig

## Elixir & Phoenix
alias Module, as: Mod
alias Phoenix, as: Phx
alias PhxHelper, as: Ph

## Data & Ops
u1 = user1 = Accounts.find_user(1)
s1 = scope1 = Accounts.user_scope(1)
# A.create_user_api_token(A.find_user(1))
# UserAuth.get_login_magic_link_url(A.find_user(1))

## Ehelper helpers

if Code.ensure_loaded?(Mix) do
  # if in Mix available
  # Mix.Local.append_archives()
  ## Add ehelper into beam code path
  Mix.path_for(:archives)
  |> Path.join("ehelper*/ehelper*")
  |> Path.wildcard()
  |> Enum.map(fn p ->
    ebin_path = Path.join(p, "ebin")
    Code.append_path(ebin_path, cache: true)
  end)

  # :code.get_path()|> Enum.map(&to_string/1)|> Enum.sort()
  Ehelper.start!()
end

# H.hi
alias Ehelper, as: H
import_if_available(Ehelper.Iex)
