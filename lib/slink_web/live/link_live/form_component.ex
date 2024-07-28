defmodule SlinkWeb.LinkLive.FormComponent do
  require Logger
  use SlinkWeb, :live_component

  alias Slink.Links

  @impl true
  def render(assigns) do
    Logger.debug("LinkLive.FormComponent rendering with assigns: #{assigns |> inspect}")

    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage link records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="link-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:url]} type="url" label="URL" placeholder="url..." />
        <:actions>
          <.button phx-disable-with="Saving...">Save Link</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    Logger.debug("LinkLive.FormComponent mounting with socket: #{socket |> inspect}")
    {:ok, socket}
  end

  @impl true
  def update(%{link: link} = assigns, socket) do
    Logger.debug(
      "LinkLive.FormComponent updating with assigns: #{assigns |> inspect} socket: #{socket |> inspect}"
    )

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Links.change_link(link))
     end)}
  end

  @impl true
  def handle_event("validate", %{"link" => link_params}, socket) do
    changeset = Links.change_link(socket.assigns.link, link_params)

    Logger.debug(
      "handle_event validate link-params: #{link_params |> inspect} with changeset: #{changeset |> inspect}"
    )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"link" => link_params}, socket) do
    Logger.debug("handle_event save link-params: #{link_params |> inspect}")
    save_link(socket, socket.assigns.action, link_params)
  end

  defp save_link(socket, :edit, link_params) do
    case Links.update_link(socket.assigns.link, link_params) do
      {:ok, link} ->
        # notify_parent({:saved, link})
        notify_parent({:updated, link})

        {:noreply,
         socket
         |> put_flash(:info, "Link updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_link(socket, :new, link_params) do
    case Links.create_link_from(socket.assigns.link, link_params) do
      {:ok, link} ->
        notify_parent({:saved, link})

        {:noreply,
         socket
         |> put_flash(:info, "Link created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("#{inspect(changeset)}")
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
