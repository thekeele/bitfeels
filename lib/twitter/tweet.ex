defmodule Bitfeels.Tweet do
  # use Ecto.Schema

  # import Ecto.{Changeset, Query}

  # alias ExFeels.{Twitter.User, Repo}

  # @fields [
  #   :text, :retweet_count, :lang, :tweet_id, :favorite_count, :created_at, :hashtags
  # ]

  # schema "tweets" do
  #   field :text, :string
  #   field :retweet_count, :integer
  #   field :lang, :string
  #   field :tweet_id, :integer
  #   field :favorite_count, :integer
  #   field :created_at, :string
  #   field :hashtags, {:array, :string}

  #   has_one :user, User

  #   timestamps()
  # end

  def parse_to_tweet(status) when is_map(status) do
    status
    |> Map.take(["created_at", "id","retweet_count", "favorite_count", "lang"])
    |> Map.put("text", parse_tweet_text(status))
    |> Map.put("hashtags", parse_hashtags(status))
    |> Map.put("user", parse_user(status))
  end

  defp parse_tweet_text(%{"extended_tweet" => %{"full_text" => text}}),
    do: text

  defp parse_tweet_text(%{"retweeted_status" => status}),
    do: status["extended_tweet"]["full_text"] || status["text"]

  defp parse_tweet_text(%{"quoted_status" => status}),
    do: status["extended_tweet"]["full_text"] || status["text"]

  defp parse_tweet_text(%{"text" => text}),
    do: text

  defp parse_hashtags(%{"entities" => %{"hashtags" => hashtags}}),
    do: Enum.map(hashtags, & &1["text"])

  defp parse_user(%{"user" => user}) do
    keys = [
      "id",
      "screen_name",
      "followers_count",
      "favourites_count",
      "time_zone",
      "verified",
      "statuses_count"
    ]

    Map.take(user, keys)
  end

  # def changeset(struct \\ %__MODULE__{}, params \\ %{}, user \\ %User{}) do
  #   params = Map.put(params, "tweet_id", params["id"])
  #   params = Map.put(params, "text", params["full_text"])

  #   struct
  #   |> cast(params, @fields)
  #   |> unique_constraint(:tweet_id)
  #   |> put_assoc(:user, user)
  # end

  # def create(params, user) do
  #   %__MODULE__{}
  #   |> changeset(params, user)
  #   |> Repo.insert()
  #   |> case do
  #     {:ok, tweet} -> tweet

  #     error -> error
  #   end
  # end

  # def create_all(tweets) when is_list(tweets) do
  #   for tweet <- tweets do
  #     {:ok, user} = User.upsert(tweet["user"]["id"], tweet["user"])

  #     tweet
  #     |> Map.delete("user")
  #     |> create(user)
  #   end
  # end

  # def get(id) do
  #   __MODULE__
  #   |> preload(:user)
  #   |> where(id: ^id)
  #   |> Repo.one()
  # end

  # def all() do
  #   __MODULE__
  #   |> preload(:user)
  #   |> Repo.all()
  # end

  # def count(), do: Repo.aggregate(__MODULE__, :count, :id)
end
