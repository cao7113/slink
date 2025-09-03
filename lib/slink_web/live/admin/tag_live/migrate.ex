defmodule SlinkWeb.Admin.TagLive.Migrate do
  use SlinkWeb, :live_view

  alias Slink.Tags
  alias Slink.Links

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>
          Migrate Current tag: <span class="text-red-600">{@tag.name}</span>(id={@tag.id})
          links to another tag.
        </:subtitle>
        <:actions>
          <.button navigate={~p"/admin/tags"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/tags/#{@tag}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit tag
          </.button>
        </:actions>
      </.header>

      <div :if={@target_tag}>
        Target tag name: <span class="text-red-600">{@target_tag.name}</span>
        with tag-id={@target_tag.id}
      </div>

      <.form for={@form} id="tag-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:target_tag_name]}
          type="text"
          label="Target Tag"
          class="input"
          phx-debounce="blur"
          required
          autofocus
        />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Tag</.button>
          <.button navigate={return_path(@current_scope, @return_to, @tag)}>Back</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id} = params, _session, socket) do
    tag = Tags.get_tag!(socket.assigns.current_scope, id)

    {:ok,
     socket
     |> assign(:page_title, "Migrate Tag Links")
     |> assign(:form, to_form(params))
     |> assign(:tag, tag)
     |> assign(:target_tag, nil)
     |> assign(:return_to, return_to(params["return_to"]))}
  end

  @impl true
  def handle_event("validate", %{"target_tag_name" => target_tag_name} = params, socket) do
    target_tag = Tags.get_by_name(target_tag_name)
    current_tag = socket.assigns.tag

    socket =
      if target_tag do
        if target_tag.id == current_tag.id do
          socket
          |> put_flash(:error, "Same tag #{target_tag_name}")
        else
          socket
          |> clear_flash()
          |> assign(:target_tag, target_tag)
        end
      else
        socket
        |> put_flash(:error, "Non-exist target tag name #{target_tag_name}")
      end

    {:noreply, assign(socket, form: to_form(params, action: :validate))}
  end

  def handle_event("save", _params, socket) do
    {:ok,
     %{
       migrated_count: cnt
     }} =
      Links.migrate_tag(socket.assigns.tag.id, socket.assigns.target_tag.id)

    socket = socket |> put_flash(:info, "Migrated #{cnt} link-tags!")
    {:noreply, socket}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp return_path(_scope, "index", _tag), do: ~p"/admin/tags"
  defp return_path(_scope, "show", tag), do: ~p"/admin/tags/#{tag}"
end
