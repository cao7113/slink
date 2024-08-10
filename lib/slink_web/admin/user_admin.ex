defmodule SlinkWeb.Admin.UserLive do
  use Backpex.LiveResource,
    layout: {SlinkWeb.Layouts, :admin},
    schema: Slink.Accounts.User,
    repo: Slink.Repo,
    update_changeset: &Slink.Accounts.User.changeset/2,
    create_changeset: &Slink.Accounts.User.changeset/2,
    pubsub: Slink.PubSub,
    topic: "users",
    event_prefix: "user_"

  @impl Backpex.LiveResource
  def singular_name, do: "User"

  @impl Backpex.LiveResource
  def plural_name, do: "Users"

  @impl Backpex.LiveResource
  def fields do
    [
      email: %{
        module: Backpex.Fields.Text,
        label: "Email"
      },
      # url: %{
      #   module: Backpex.Fields.Text,
      #   label: "URL"
      # },
      inserted_at: %{
        module: Backpex.Fields.Text,
        label: "Inserted At"
      }
    ]
  end
end
