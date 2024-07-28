defmodule SlinkWeb.LinkController do
  use SlinkWeb, :controller

  alias Slink.Links
  alias Slink.Links.Link

  import SlinkWeb.UserAuth

  plug :require_api_user when action in [:create, :update, :delete]
  action_fallback SlinkWeb.FallbackController

  def index(conn, _params) do
    links = Links.list_links()
    render(conn, :index, links: links)
  end

  def create(conn, %{"link" => link_params}) do
    link_params =
      link_params
      |> Map.put("user_id", conn.assigns.current_user.id)

    with {:ok, %Link{} = link} <- Links.create_link(link_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/links/#{link}")
      |> render(:show, link: link)
    end
  end

  def show(conn, %{"id" => id}) do
    link = Links.get_link!(id)
    render(conn, :show, link: link)
  end

  def update(conn, %{"id" => id, "link" => link_params}) do
    link = Links.get_link!(id)

    with {:ok, %Link{} = link} <- Links.update_link(link, link_params) do
      render(conn, :show, link: link)
    end
  end

  def delete(conn, %{"id" => id}) do
    link = Links.get_link!(id)

    with {:ok, %Link{}} <- Links.delete_link(link) do
      send_resp(conn, :no_content, "")
    end
  end
end
