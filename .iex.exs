## Ecto
alias Ecto.Changeset
import Ecto.Query

## Slink
alias Slink, as: S
alias Slink.Repo
alias Slink.Accounts
alias Slink.Accounts.User
alias Slink.Accounts.UserToken
alias Slink.Accounts.AdminUser
alias Slink.Links
alias Slink.Links.Link
# alias Slink.Sites
# alias Slink.Sites.Site
# alias Slink.Tags
# alias Slink.Tags.Tag

## Helpers
alias Slink.Fixtures
# alias ProcessHelper, as: Ph

defmodule I do
  def blanks(n \\ 20) do
    1..n
    |> Enum.each(fn _ ->
      IO.puts("")
    end)
  end
end
