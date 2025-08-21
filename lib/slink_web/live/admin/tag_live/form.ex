defmodule SlinkWeb.Admin.TagLive.Form do
  use SlinkWeb, :live_view

  alias Slink.Tags
  alias Slink.Tags.Tag

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage tag records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="tag-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" class="input" autofocus />
        <.input field={@form[:group]} type="text" label="Group" class="input" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Tag</.button>
          <.button navigate={return_path(@current_scope, @return_to, @tag)}>Cancel</.button>
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
    tag = Tags.get_tag!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Tag")
    |> assign(:tag, tag)
    |> assign(:form, to_form(Tags.change_tag(socket.assigns.current_scope, tag)))
  end

  defp apply_action(socket, :new, _params) do
    tag = %Tag{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Tag")
    |> assign(:tag, tag)
    |> assign(:form, to_form(Tags.change_tag(socket.assigns.current_scope, tag)))
  end

  @impl true
  def handle_event("validate", %{"tag" => tag_params}, socket) do
    changeset = Tags.change_tag(socket.assigns.current_scope, socket.assigns.tag, tag_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"tag" => tag_params}, socket) do
    save_tag(socket, socket.assigns.live_action, tag_params)
  end

  defp save_tag(socket, :edit, tag_params) do
    case Tags.update_tag(socket.assigns.current_scope, socket.assigns.tag, tag_params) do
      {:ok, tag} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tag updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, tag)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_tag(socket, :new, tag_params) do
    case Tags.create_tag(socket.assigns.current_scope, tag_params) do
      {:ok, tag} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tag created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, tag)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _tag), do: ~p"/admin/tags"
  defp return_path(_scope, "show", tag), do: ~p"/admin/tags/#{tag}"
end
