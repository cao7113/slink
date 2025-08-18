defmodule SlinkWeb.My.UserLinkLive.Form do
  use SlinkWeb, :live_view

  alias Slink.UserLinks
  alias Slink.Links.UserLink

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage user_link records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="user_link-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:note]} type="textarea" label="Note" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save User link</.button>
          <.button navigate={return_path(@current_scope, @return_to, @user_link)}>Cancel</.button>
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
    user_link = UserLinks.get_user_link!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit User link")
    |> assign(:user_link, user_link)
    |> assign(:form, to_form(UserLinks.change_user_link(socket.assigns.current_scope, user_link)))
  end

  defp apply_action(socket, :new, _params) do
    user_link = %UserLink{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New User link")
    |> assign(:user_link, user_link)
    |> assign(:form, to_form(UserLinks.change_user_link(socket.assigns.current_scope, user_link)))
  end

  @impl true
  def handle_event("validate", %{"user_link" => user_link_params}, socket) do
    changeset =
      UserLinks.change_user_link(
        socket.assigns.current_scope,
        socket.assigns.user_link,
        user_link_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"user_link" => user_link_params}, socket) do
    save_user_link(socket, socket.assigns.live_action, user_link_params)
  end

  defp save_user_link(socket, :edit, user_link_params) do
    case UserLinks.update_user_link(
           socket.assigns.current_scope,
           socket.assigns.user_link,
           user_link_params
         ) do
      {:ok, user_link} ->
        {:noreply,
         socket
         |> put_flash(:info, "User link updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, user_link)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_user_link(socket, :new, user_link_params) do
    case UserLinks.create_user_link(socket.assigns.current_scope, user_link_params) do
      {:ok, user_link} ->
        {:noreply,
         socket
         |> put_flash(:info, "User link created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, user_link)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _user_link), do: ~p"/my/user_links"
  defp return_path(_scope, "show", user_link), do: ~p"/my/user_links/#{user_link}"
end
