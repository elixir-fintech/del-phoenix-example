defmodule DelExampleWeb.Router do
  use DelExampleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DelExampleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DelExampleWeb do
    pipe_through :browser

    get "/", InstanceController, :index

    # Transaction
    live "/instances/:instance_address/transactions/new", TransactionNewLive
    live "/instances/:instance_address/transactions/:transaction_id/edit", TransactionEditLive

    # Account
    live "/instances/:instance_address/accounts/new", AccountNewLive
    live "/instances/:instance_address/accounts/:account_address/edit", AccountEditLive

    resources "/instances", InstanceController, param: "address" do
      resources "/accounts", AccountController, param: "address", only: [:show, :delete] do
        resources "/transactions", TransactionController, only: [:index, :show]
      end

      resources "/events", EventController, only: [:index, :show]
      resources "/transactions", TransactionController, only: [:index, :show]
    end
  end

  # Other scopes may use custom stacks.
  scope "/api", DelExampleWeb do
    pipe_through :api

    post "/events", EventApiController, :create
    get "/:instance_address/events/:id", EventApiController, :show
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:del_example, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DelExampleWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
