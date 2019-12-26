defmodule UserAuthWeb.Router do
  use UserAuthWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", UserAuthWeb do
    pipe_through :api

    resources "/users", UserController
    post "/users/sign_in", UserController, :sign_in
  end
end
