defmodule SlinkWeb.Router do
  use SlinkWeb, :router

  import SlinkWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {SlinkWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug :get_api_user
  end

  scope "/", SlinkWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
    get("/phoenix", PageController, :phoenix)
    get("/try", PageController, :try)

    live "/live/try", TryLive
  end

  ## Links routes

  scope "/", SlinkWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_user_to_link_ops,
      on_mount: [{SlinkWeb.UserAuth, :ensure_authenticated}] do
      live "/links/new", LinkLive.Index, :new
      live "/links/:id/edit", LinkLive.Index, :edit
      live "/links/:id/show/edit", LinkLive.Show, :edit
    end
  end

  scope "/", SlinkWeb do
    pipe_through(:browser)

    live_session :mount_user_to_link,
      on_mount: [{SlinkWeb.UserAuth, :mount_current_user}] do
      live "/links", LinkLive.Index, :index
      live "/links/:id", LinkLive.Show, :show
    end
  end

  ## API routes

  scope "/api", SlinkWeb do
    pipe_through(:api)
    get("/ping", ApiController, :ping)

    # Links API
    resources "/links", LinkController, except: [:new, :edit]
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
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: SlinkWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Admin Panel

  import Backpex.Router

  scope "/admin", SlinkWeb.Admin do
    pipe_through :browser
    backpex_routes()

    live_session :admin_panel,
      on_mount: [
        Backpex.InitAssigns,
        {SlinkWeb.UserAuth, :ensure_authenticated_for_admin},
        {SlinkWeb.UserAuth, :check_admin_user}
      ] do
      live_resources("/", LinkLive)
      live_resources("/users", UserLive)
      live_resources("/user_tokens", UserTokenLive)
      live_resources("/admin_users", AdminUserLive)
      live_resources("/links", LinkLive)
    end
  end

  ## Authentication routes

  scope "/", SlinkWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{SlinkWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", SlinkWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{SlinkWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/users/api-tokens", ApiTokenLive
    end
  end

  scope "/", SlinkWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{SlinkWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
