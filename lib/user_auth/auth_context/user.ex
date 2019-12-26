defmodule UserAuth.AuthContext.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string, null: false
    field :password_hash, :string
    field :is_active, :boolean, default: false
    field :password, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :is_active])
    |> validate_required([:email, :password, :is_active])
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(
    %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Bcrypt.add_hash(password))
  end
  defp put_password_hash(changeset) do
    changeset
  end
end
