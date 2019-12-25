defmodule UserAuth.Repo do
  use Ecto.Repo,
    otp_app: :user_auth,
    adapter: Ecto.Adapters.Postgres
end
