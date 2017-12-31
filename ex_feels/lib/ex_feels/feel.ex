defmodule ExFeels.Feel do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Query

  alias ExFeels.{Twitter.Tweet, Repo}

  schema "feels" do
    field :classifier, :string
    field :sentiment, :string

    belongs_to :tweet, Tweet

    timestamps()
  end

  def get(id) do
    __MODULE__
    |> where(id: ^id)
    |> preload(:tweet)
    |> Repo.one()
  end

  def all() do
    __MODULE__
    |> preload(:tweet)
    |> Repo.all()
  end
end