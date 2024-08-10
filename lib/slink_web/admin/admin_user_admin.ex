defmodule SlinkWeb.Admin.AdminUserLive do
  alias Slink.Accounts.AdminUser, as: Model

  use Backpex.LiveResource,
    layout: {SlinkWeb.Layouts, :admin},
    schema: Model,
    repo: Slink.Repo,
    # &Model.changeset/2,
    update_changeset: nil,
    # &Model.changeset/2,
    create_changeset: nil,
    pubsub: Slink.PubSub,
    topic: "user_tokens",
    event_prefix: "user_token_"

  @impl Backpex.LiveResource
  def singular_name, do: "AdminUser"

  @impl Backpex.LiveResource
  def plural_name, do: "AdminUsers"

  @impl Backpex.LiveResource
  def fields do
    [
      id: %{
        module: Backpex.Fields.Number,
        label: "ID"
      },
      user_id: %{
        module: Backpex.Fields.Number,
        label: "User ID"
      },
      role: %{
        module: Backpex.Fields.Text,
        label: "Role"
      },
      by_admin_id: %{
        module: Backpex.Fields.Text,
        label: "By Admin ID"
      },
      inserted_at: %{
        module: Backpex.Fields.Text,
        label: "Inserted At"
      }
    ]
  end
end
