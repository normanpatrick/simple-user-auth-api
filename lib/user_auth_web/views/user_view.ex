defmodule UserAuthWeb.UserView do
  use UserAuthWeb, :view
  alias UserAuthWeb.UserView

  def render("index.json", %{users: users}) do
    render_many(users, UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email,
      is_active: user.is_active}
  end

  def render("sign_in.json", %{user: user}) do
    %{user: %{
         id: user.id,
         email: user.email
      }
    }
  end

  def render("error.json", %{message: message}) do
    %{errors: %{details: message}}
  end
end
