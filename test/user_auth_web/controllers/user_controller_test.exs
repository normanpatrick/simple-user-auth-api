defmodule UserAuthWeb.UserControllerTest do
  use UserAuthWeb.ConnCase

  alias UserAuth.AuthContext
  alias UserAuth.AuthContext.User
  alias Plug.Test

  @create_attrs %{
    email: "some email",
    is_active: true,
    password: "some password"
  }
  @update_attrs %{
    email: "some updated email",
    is_active: false,
    password: "some updated password"
  }
  @invalid_attrs %{email: nil, is_active: nil, password: nil}
  @current_user_attrs %{
    email: "some current user email",
    is_active: true,
    password: "some current user password"
  }

  def fixture(:user) do
    {:ok, user} = AuthContext.create_user(@create_attrs)
    %{ user | password: nil}
  end

  def fixture(:current_user) do
    {:ok, current_user} = AuthContext.create_user(@current_user_attrs)
    current_user
  end

  setup %{conn: conn} do
    {:ok, conn: conn, current_user: current_user} = setup_current_user(conn)
    {
      :ok,
      conn: put_req_header(conn, "accept", "application/json"),
      current_user: current_user
    }
  end

  defp setup_current_user(conn) do
    current_user = fixture(:current_user)
    {
      :ok,
      conn: Test.init_test_session(conn, current_user_id: current_user.id),
      current_user: current_user
    }
  end

  describe "index" do
    test "lists all users", %{conn: conn, current_user: current_user} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 200) ==
        [%{
            "id" => current_user.id,
            "email" => current_user.email,
            "is_active" => current_user.is_active
         }]
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "some email",
               "is_active" => true,
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "some updated email",
               "is_active" => false,
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  describe "authenticate user" do
    @login_user %{
      email: "someone@somewhere1234.com",
      is_active: true,
      password: "password1234"
    }
    test "authenticate successfully", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @login_user)
      assert %{} = json_response(conn, 201)

      conn = post(conn, Routes.user_path(conn, :sign_in, @login_user))
      assert %{"user" => %{"email" => email, "id" => id}} = json_response(conn, 200)
    end
    test "failed authentication due to bad password", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @login_user)
      assert %{} = json_response(conn, 201)

      conn = post(conn, Routes.user_path(conn, :sign_in,
            %{@login_user | password: "bad password"}))
      assert %{"errors" => %{"details" => "Wrong email or passowrd"}} =
        json_response(conn, 401)
    end
    test "failed authentication due to bad username", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @login_user)
      assert %{} = json_response(conn, 201)

      conn = post(conn, Routes.user_path(conn, :sign_in,
            %{@login_user | email: "bad-email"}))
      assert %{"errors" => %{"details" => "Wrong email or passowrd"}} =
        json_response(conn, 401)
    end
    test "failed authentication due to non-existent user", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :sign_in, @login_user))
      assert %{"errors" => %{"details" => "Wrong email or passowrd"}} =
        json_response(conn, 401)
    end
  end

  describe "CORS tests" do
    test "preflight request for :create", %{conn: conn} do
      assert "" =
        conn
        |> put_req_header("origin", "http://foo.com")
        |> put_req_header("access-control-request-method", "POST")
        |> options(Routes.user_path(conn, :create), user: @create_attrs)
        |> response(200)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
