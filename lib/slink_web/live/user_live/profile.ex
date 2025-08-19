defmodule SlinkWeb.UserLive.Profile do
  use SlinkWeb, :live_view

  alias Slink.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="text-center">
        <.header>
          User Profile
          <:subtitle>Manage your user name, bio and site settings</:subtitle>
        </.header>
      </div>

      <.form
        for={@profile_form}
        id="profile_form"
        phx-submit="update_profile"
        phx-change="validate_profile"
      >
        <.input
          field={@profile_form[:name]}
          type="text"
          label="Name"
          autocomplete="username"
          required
        />
        <.input
          field={@profile_form[:bio]}
          type="textarea"
          label="Bio"
        />
        <.input
          field={@profile_form[:site]}
          type="text"
          label="Site"
        />
        <.input
          field={@profile_form[:avatar_url]}
          type="text"
          label="Avatar URL"
        />
        <.button variant="primary" phx-disable-with="Changing...">Change Profile</.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    changeset = Accounts.change_profile(user, %{})

    socket =
      socket
      |> assign(:profile_form, to_form(changeset))

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_profile", params, socket) do
    %{"user" => user_params} = params

    profile_form =
      socket.assigns.current_scope.user
      |> Accounts.change_profile(user_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, profile_form: profile_form)}
  end

  def handle_event("update_profile", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user

    case Accounts.change_profile(user, user_params) do
      %{valid?: true} = changeset ->
        Slink.Repo.update!(changeset)

        info = "Profile updated successfully."
        {:noreply, socket |> put_flash(:info, info)}

      changeset ->
        {:noreply, assign(socket, :profile_form, to_form(changeset, action: :insert))}
    end
  end
end
