defmodule Bitfeels.Repo do
  use Ecto.Repo,
    otp_app: :bitfeels,
    adapter: Ecto.Adapters.Postgres
end
