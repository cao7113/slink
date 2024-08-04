defmodule SlinkWeb.Admin.LinkLive do
  use Backpex.LiveResource,
    layout: {SlinkWeb.Layouts, :admin},
    schema: Slink.Links.Link,
    repo: Slink.Repo,
    update_changeset: &Slink.Links.Link.update_changeset/3,
    create_changeset: &Slink.Links.Link.create_changeset/3,
    pubsub: Slink.PubSub,
    topic: "links",
    event_prefix: "link_"

  @impl Backpex.LiveResource
  def singular_name, do: "Link"

  @impl Backpex.LiveResource
  def plural_name, do: "Links"

  @impl Backpex.LiveResource
  def fields do
    [
      title: %{
        module: Backpex.Fields.Text,
        label: "Title"
      },
      url: %{
        module: Backpex.Fields.Text,
        label: "URL"
      }
    ]
  end
end
