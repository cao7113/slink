defmodule SlinkWeb.Api.LinkController do
  use SlinkWeb, :controller

  alias Slink.Links
  alias Slink.Links.Link

  action_fallback SlinkWeb.FallbackController
  require Logger

  def create(conn, %{"link" => link_params}) do
    Logger.info("Creating link with params: #{link_params |> inspect}!")

    with {:ok, %Link{} = link} <- Links.create_link(conn.assigns.current_scope, link_params) do
      Logger.info("Created link with ID: #{link.id} with params: #{link_params |> inspect}!")

      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/links/#{link}")
      |> render(:show, link: link)
    else
      err ->
        Logger.info("create link failed: #{err |> inspect}")
        err
    end
  end

  def index(conn, _params) do
    links = Links.list_links(conn.assigns.current_scope)
    render(conn, :index, links: links)
  end

  def show(conn, %{"id" => id}) do
    link = Links.get_link!(conn.assigns.current_scope, id)
    render(conn, :show, link: link)
  end

  def update(conn, %{"id" => id, "link" => link_params}) do
    link = Links.get_link!(conn.assigns.current_scope, id)

    with {:ok, %Link{} = link} <- Links.update_link(conn.assigns.current_scope, link, link_params) do
      Logger.info("Updated link with ID: #{link.id} with params: #{link_params |> inspect}!")
      render(conn, :show, link: link)
    end
  end

  def delete(conn, %{"id" => id}) do
    link = Links.get_link!(conn.assigns.current_scope, id)

    with {:ok, %Link{}} <- Links.delete_link(conn.assigns.current_scope, link) do
      Logger.info(
        "Deleted link with ID: #{link.id} with attrs: #{link |> Map.take([:title, :url, :user_id, :inserted_at, :updated_at])}!"
      )

      send_resp(conn, :no_content, "")
    end
  end
end
