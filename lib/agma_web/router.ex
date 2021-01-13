defmodule AgmaWeb.Router do
  use AgmaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AgmaWeb do
    pipe_through :api
  end
end
