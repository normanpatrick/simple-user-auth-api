defmodule UserAuthWeb.Router do
  use UserAuthWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :authenticate_api do
    plug :ensure_authenticated
  end

  scope "/api", UserAuthWeb do
    pipe_through :api
    post "/users/sign_in", UserController, :sign_in
  end

  scope "/api", UserAuthWeb do
    pipe_through [:api, :authenticate_api]
    resources "/users", UserController
  end

  defp ensure_authenticated(conn, _opts) do
    current_user_id = get_session(conn, :current_user_id)
    if current_user_id do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(UserAuthWeb.UserView)
      |> render("error.json", message: "User not authenticated")
      |> halt()
    end
  end
end
