defmodule ExFeels.Feel do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Query

  alias ExFeels.{Twitter.Tweet, Repo}

  @env Mix.env()

  schema "feels" do
    field :classifier, :string
    field :sentiment, :string

    belongs_to :tweet, Tweet

    timestamps()
  end

  def generate() do
    task = Task.async(&binary_classifier/0)

    Task.await(task, 10_000)
  end

  defp binary_classifier() do
    "python"
    |> System.cmd(["binary_classifier.py", "#{@env}"], cd: "../py_feels/binary")
    |> case do
      {_, 0} -> :ok

      _ -> :error
    end
  end

  def get(id) do
    __MODULE__
    |> where(id: ^id)
    |> preload(:tweet)
    |> Repo.one()
  end

  def all(params) do
    __MODULE__
    |> join(:inner, [f], t in Tweet, f.tweet_id == t.id)
    |> order_by([f, t], desc: t.id)
    |> select([f, t], %{
      tweet: %{
        id: t.id,
        text: t.text,
        created_at: t.created_at
      },
      sentiment: f.sentiment,
      classifier: f.classifier
    })
    |> Repo.paginate(params)
  end
end
