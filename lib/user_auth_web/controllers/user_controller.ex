defmodule UserAuthWeb.UserController do
  use UserAuthWeb, :controller

  alias UserAuth.AuthContext
  alias UserAuth.AuthContext.User

  action_fallback UserAuthWeb.FallbackController

  def index(conn, _params) do
    users = AuthContext.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- AuthContext.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = AuthContext.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = AuthContext.get_user!(id)

    with {:ok, %User{} = user} <- AuthContext.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = AuthContext.get_user!(id)

    with {:ok, %User{}} <- AuthContext.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case UserAuth.AuthContext.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_status(:ok)
        |> render("sign_in.json", user: user)
      {:error, message} ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", message: message)
    end
  end
end
