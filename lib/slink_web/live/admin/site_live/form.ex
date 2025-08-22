defmodule SlinkWeb.Admin.SiteLive.Form do
  use SlinkWeb, :live_view

  alias Slink.Sites
  alias Slink.Sites.Site

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage site records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="site-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:url]} type="text" label="Url" />
        <.input field={@form[:logo_url]} type="text" label="Logo url" />
        <.input field={@form[:category]} type="text" label="Category" />
        <.input field={@form[:intro]} type="textarea" label="Intro" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Site</.button>
          <.button navigate={return_path(@current_scope, @return_to, @site)}>Cancel</.button>
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
    site = Sites.get_site!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Site")
    |> assign(:site, site)
    |> assign(:form, to_form(Sites.change_site(socket.assigns.current_scope, site)))
  end

  defp apply_action(socket, :new, _params) do
    site = %Site{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Site")
    |> assign(:site, site)
    |> assign(:form, to_form(Sites.change_site(socket.assigns.current_scope, site)))
  end

  @impl true
  def handle_event("validate", %{"site" => site_params}, socket) do
    changeset = Sites.change_site(socket.assigns.current_scope, socket.assigns.site, site_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"site" => site_params}, socket) do
    save_site(socket, socket.assigns.live_action, site_params)
  end

  defp save_site(socket, :edit, site_params) do
    case Sites.update_site(socket.assigns.current_scope, socket.assigns.site, site_params) do
      {:ok, site} ->
        {:noreply,
         socket
         |> put_flash(:info, "Site updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, site)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_site(socket, :new, site_params) do
    case Sites.create_site(socket.assigns.current_scope, site_params) do
      {:ok, site} ->
        {:noreply,
         socket
         |> put_flash(:info, "Site created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, site)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _site), do: ~p"/admin/sites"
  defp return_path(_scope, "show", site), do: ~p"/admin/sites/#{site}"
end
