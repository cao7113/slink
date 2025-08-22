defmodule SlinkWeb.Router do
  use SlinkWeb, :router

  import SlinkWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SlinkWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_current_scope_for_api_user
  end

  scope "/", SlinkWeb do
    pipe_through :browser

    get "/home", PageController, :home
    get "/daisyui", PageController, :daisyui
  end

  # API
  scope "/api", SlinkWeb.Api do
    pipe_through :api

    get "/", ToolsController, :home
    get "/ping", ToolsController, :ping
    get "/info", ToolsController, :info

    scope "/" do
      # todo should be dev-ops route
      pipe_through [:require_authenticated_api_user]

      get "/info/builder", ToolsController, :build_info
    end

    # resources "/links", Api.LinkController, except: [:new, :edit]
    get "/links", LinkController, :index
    get "/links/:id", LinkController, :show

    scope "/links" do
      pipe_through [:require_authenticated_api_user]

      post "/", LinkController, :create
      put "/:id", LinkController, :update
      patch "/:id", LinkController, :update
      delete "/:id", LinkController, :delete
    end

    scope "/" do
      # todo should be dev-ops route
      pipe_through [:require_authenticated_api_user]

      post "/user_links/collect", UserLinkController, :collect
      resources "/user_links", UserLinkController, except: [:new, :edit]
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:slink, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SlinkWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", SlinkWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{SlinkWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email

      live "/users/profile", UserLive.Profile, :edit

      scope "/my", My do
        live "/links", LinkLive.Index, :index
        live "/links/new", LinkLive.Form, :new
        live "/links/:id", LinkLive.Show, :show
        live "/links/:id/edit", LinkLive.Form, :edit

        live "/user_links", UserLinkLive.Index, :index
        live "/user_links/new", UserLinkLive.Form, :new
        live "/user_links/:id", UserLinkLive.Show, :show
        live "/user_links/:id/edit", UserLinkLive.Form, :edit

        live "/user_tokens", UserTokenLive.Index, :index
      end
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", SlinkWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{SlinkWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new

      # public links show
      live "/", LinkLive.Index, :index
      live "/links", LinkLive.Index, :index
      live "/links/new", LinkLive.Form, :new
      live "/links/:id", LinkLive.Show, :show
      live "/links/:id/edit", LinkLive.Form, :edit
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  ## Admin routes

  scope "/", SlinkWeb do
    pipe_through [:browser, :require_authenticated_admin_user]

    live_session :require_authenticated_admin_user,
      on_mount: [{SlinkWeb.UserAuth, :require_authenticated_admin_user}] do
      scope "/admin", Admin do
        ## Users
        live "/users", UserLive.Index, :index
        live "/users/:id", UserLive.Show, :show

        ## Tags
        live "/tags", TagLive.Index, :index
        live "/tags/new", TagLive.Form, :new
        live "/tags/:id", TagLive.Show, :show
        live "/tags/:id/edit", TagLive.Form, :edit

        ## Sites
        live "/sites", SiteLive.Index, :index
        live "/sites/new", SiteLive.Form, :new
        live "/sites/:id", SiteLive.Show, :show
        live "/sites/:id/edit", SiteLive.Form, :edit
      end
    end
  end
end
