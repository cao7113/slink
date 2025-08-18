defmodule SlinkWeb.Api.UserLinkController do
  use SlinkWeb, :controller

  alias Slink.UserLinks
  alias Slink.Links.UserLink

  action_fallback SlinkWeb.FallbackController

  def collect(conn, %{"link" => link_params}) do
    link_params = Maper.atomlize_keys(link_params, ~w[title url note])

    with {:ok, %UserLink{} = user_link} <-
           UserLinks.collect_user_link(conn.assigns.current_scope, link_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/user_links/#{user_link}")
      |> render(:show, user_link: user_link)
    end
  end

  def create(conn, %{"user_link" => user_link_params}) do
    with {:ok, %UserLink{} = user_link} <-
           UserLinks.create_user_link(conn.assigns.current_scope, user_link_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/user_links/#{user_link}")
      |> render(:show, user_link: user_link)
    end
  end

  def index(conn, _params) do
    user_links = UserLinks.list_user_links(conn.assigns.current_scope)
    render(conn, :index, user_links: user_links)
  end

  def show(conn, %{"id" => id}) do
    user_link = UserLinks.get_user_link!(conn.assigns.current_scope, id)
    render(conn, :show, user_link: user_link)
  end

  def update(conn, %{"id" => id, "user_link" => user_link_params}) do
    user_link = UserLinks.get_user_link!(conn.assigns.current_scope, id)

    with {:ok, %UserLink{} = user_link} <-
           UserLinks.update_user_link(conn.assigns.current_scope, user_link, user_link_params) do
      render(conn, :show, user_link: user_link)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_link = UserLinks.get_user_link!(conn.assigns.current_scope, id)

    with {:ok, %UserLink{}} <- UserLinks.delete_user_link(conn.assigns.current_scope, user_link) do
      send_resp(conn, :no_content, "")
    end
  end
end
