defmodule Pls.Repo do
  use Ecto.Repo,
    otp_app: :pls,
    adapter: Ecto.Adapters.Postgres
end
