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
#    |> distinct([f, _], desc: f.tweet_id)
#    |> order_by([f, _], desc: f.inserted_at)
    |> select([f, t], %{
      tweet: %{text: t.text},
      sentiment: f.sentiment,
      classifier: f.classifier
    })
    |> Repo.all()
  end
end
