defmodule ExFeels.Feel do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Query

  require Logger

  alias ExFeels.{Twitter.Tweet, Repo}

  @env Mix.env()
  @py_feels [:binary_classifier, :time_series]

  schema "feels" do
    field :classifier, :string
    field :sentiment, :string

    belongs_to :tweet, Tweet

    timestamps()
  end

  def generate_feels(py_feel) do
    task = Task.async(fn -> run_script(py_feel) end)

    Task.await(task, 10_000)
  end

  defp run_script(py_feel) when py_feel in @py_feels do
    py_feel = Atom.to_string(py_feel)

    Logger.info fn ->
      """
        fired async task #{py_feel}
      """
      end

    "python"
    |> System.cmd(["#{py_feel}.py", "#{@env}"], cd: "../py_feels/binary")
    |> case do
      {_, 0} ->
        Logger.info fn ->
        """
          task #{py_feel} successful
        """
        end

        :ok

      _ ->
        Logger.info fn ->
        """
          task #{py_feel} failed
        """
        end

        :error
    end
  end

  defp run_script(py_feel) do
    Logger.info fn ->
    """
      unknown #{py_feel} feel
    """
    end

    :error
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

  def count() do
    __MODULE__
    |> Repo.aggregate(:count, :id)
  end
end
