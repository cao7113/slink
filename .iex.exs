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
alias SlinkWeb.Endpoint, as: Ep
# Ep.config :http

## Remote
alias Remote, as: R
alias EnvHelper, as: Env
alias Builder, as: B

## Testing
alias Slink.Factory
alias Slink.Factory, as: F

## Helpers
alias ProcessHelper, as: Ph
alias SchemaMigration, as: Mig

## Data & Ops
u1 = user1 = Accounts.find_user(1)
s1 = scope1 = Accounts.user_scope(1)
# A.create_user_api_token(A.find_user(1))
# UserAuth.get_login_magic_link_url(A.find_user(1))
