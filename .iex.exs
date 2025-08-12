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

# Web
alias SlinkWeb, as: Web
alias SlinkWeb.UserAuth

## Remote
alias Remote, as: R
alias EnvHelper, as: Env
alias Builder, as: B

## Testing
alias Slink.Factory
alias Slink.Factory, as: F

## Data
u1 = User.find(1)

## Ops API
# A.create_user_api_token(A.get_user!(1))
# UserAuth.get_login_magic_link_url(User.find(1))

## Helpers
alias ProcessHelper, as: Ph

## Tailwind
# get tailwind version
# iex> Tailwind.latest_version
# tailwind cli at: _build/tailwind* after run: mix tailwind.install
