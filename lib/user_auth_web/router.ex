defmodule UserAuthWeb.Router do
  use UserAuthWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", UserAuthWeb do
    pipe_through :api

    resources "/users", UserController
  end
end
