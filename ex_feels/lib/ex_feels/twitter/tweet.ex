defmodule ExFeels.Twitter.Tweet do
  use Ecto.Schema

  import Ecto.{Changeset, Query}

  alias ExFeels.{Twitter.User, Repo}

  @fields [
    :text, :retweet_count, :lang, :tweet_id, :favorite_count, :created_at, :hashtags
  ]

  schema "tweets" do
    field :text, :string
    field :retweet_count, :integer
    field :lang, :string
    field :tweet_id, :integer
    field :favorite_count, :integer
    field :created_at, :string
    field :hashtags, {:array, :string}

    has_one :user, User

    timestamps()
  end

  def parse_to_tweets(status) when is_map(status) do
    parse_to_tweets([status])
  end
  def parse_to_tweets(statuses) when is_list(statuses) do
    Enum.map(statuses, fn status ->
      status = status["retweeted_status"] || status

      status
      |> take_status_data()
      |> Map.put("hashtags", take_hashtags_data(status["entities"]["hashtags"]))
      |> Map.put("user", take_user_data(status["user"]))
    end)
  end

  def parse_to_tweets(error), do: error

  defp take_status_data(status) do
    keys = ["created_at", "id", "text", "full_text", "retweet_count", "favorite_count", "lang"]

    Map.take(status, keys)
  end

  defp take_hashtags_data(hashtags), do: Enum.map(hashtags, & &1["text"])

  defp take_user_data(user) do
    keys = [
      "id", "screen_name", "followers_count", "favourites_count", "time_zone", "verified", "statuses_count"
    ]

    Map.take(user, keys)
  end

  def changeset(struct \\ %__MODULE__{}, params \\ %{}, user \\ %User{}) do
    params = Map.put(params, "tweet_id", params["id"])
    params = Map.put(params, "text", params["full_text"])

    struct
    |> cast(params, @fields)
    |> unique_constraint(:tweet_id)
    |> put_assoc(:user, user)
  end

  def create(params, user) do
    %__MODULE__{}
    |> changeset(params, user)
    |> Repo.insert()
    |> case do
      {:ok, tweet} -> tweet

      error -> error
    end
  end

  def create_all(tweets) when is_list(tweets) do
    for tweet <- tweets do
      {:ok, user} = User.upsert(tweet["user"]["id"], tweet["user"])

      tweet
      |> Map.delete("user")
      |> create(user)
    end
  end

  def get(id) do
    __MODULE__
    |> preload(:user)
    |> where(id: ^id)
    |> Repo.one()
  end

  def all() do
    __MODULE__
    |> preload(:user)
    |> Repo.all()
  end

  def count(), do: Repo.aggregate(__MODULE__, :count, :id)
end
