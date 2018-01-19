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
    |> join(:inner, [f], t in Tweet, f.tweet_id == t.id)
    |> select([f, t], %{
      tweet: %{
        text: t.text,
        created_at: t.created_at
      },
      sentiment: f.sentiment,
      classifier: f.classifier
    })
    |> Repo.all()
  end
end
