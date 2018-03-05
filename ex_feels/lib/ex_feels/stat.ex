defmodule ExFeels.Stat do
  @moduledoc false

  use Ecto.Schema

  alias ExFeels.Repo

  @primary_key false
  schema "stats" do
    field :classifier, :string
    field :mean, :float
    field :std, :float
    field :time, :string
  end

  def all() do
    Repo.all(__MODULE__)
  end

  def count() do
    __MODULE__
    |> Repo.aggregate(:count, :time)
  end
end
