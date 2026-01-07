defmodule SlinkWeb.LinkLive.Form do
  use SlinkWeb, :live_view

  alias Slink.Links
  alias Slink.Links.Link

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage link records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="link-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:url]} type="text" label="Url" />
        <.input field={@form[:input_tags]} type="text" label="Tags(comma separated)" autofocus />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Link</.button>
          <.button navigate={return_path(@current_scope, @return_to, @link)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    link =
      Links.get_link!(socket.assigns.current_scope, id)
      |> Slink.Repo.preload(:tags)

    link = %{link | input_tags: Slink.Tags.tags_string(link.tags)}

    socket
    |> assign(:page_title, "Edit Link")
    |> assign(:link, link)
    |> assign(:form, to_form(Links.change_link(socket.assigns.current_scope, link)))
  end

  defp apply_action(socket, :new, _params) do
    link = %Link{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Link")
    |> assign(:link, link)
    |> assign(:form, to_form(Links.change_link(socket.assigns.current_scope, link)))
  end

  @impl true
  def handle_event("validate", %{"link" => link_params}, socket) do
    changeset = Links.change_link(socket.assigns.current_scope, socket.assigns.link, link_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"link" => link_params}, socket) do
    save_link(socket, socket.assigns.live_action, link_params)
  end

  defp save_link(socket, :edit, link_params) do
    case Links.update_link(socket.assigns.current_scope, socket.assigns.link, link_params) do
      {:ok, link} ->
        {:noreply,
         socket
         |> put_flash(:info, "Link updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, link)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_link(socket, :new, link_params) do
    case Links.create_link(socket.assigns.current_scope, link_params) do
      {:ok, link} ->
        {:noreply,
         socket
         |> put_flash(:info, "Link created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, link)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _link), do: ~p"/links"
  defp return_path(_scope, "show", link), do: ~p"/links/#{link}"
end
