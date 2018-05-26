defmodule ExFeels.Feel do
  use Ecto.Schema

  import Ecto.Query

  alias ExFeels.{Twitter.Tweet, Repo}

  @env Mix.env()
  @py_feels [:binary_classifier, :time_series]

  schema "feels" do
    field :classifier, :string
    field :sentiment, :string

    belongs_to :tweet, Tweet

    timestamps()
  end

  def generate_feels(py_feels) when is_list(py_feels) do
    Enum.map(py_feels, &generate_feels/1)
  end
  def generate_feels(py_feel) when is_atom(py_feel) do
    task = Task.async(fn -> run_py_feel(py_feel) end)

    Task.await(task, 10_000)
  end

  defp run_py_feel(py_feel) when py_feel in @py_feels do
    py_feel = Atom.to_string(py_feel)

    case System.cmd("python", ["#{py_feel}.py", "#{@env}"], cd: "../py_feels/binary") do
      {_, 0} -> :ok

      _error -> :error
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

  def count(), do: Repo.aggregate(__MODULE__, :count, :id)
end
