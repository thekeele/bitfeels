defmodule ExFeels.Twitter.Tweet do
  @moduledoc false

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
    field :created_at, :naive_datetime
    field :hashtags, {:array, :string}

    has_one :user, User

    timestamps()
  end

  def changeset(struct \\ %__MODULE__{}, params \\ %{}, user \\ %User{}) do
    struct
    |> cast(params, @fields)
    |> put_assoc(:user, user)
  end

  def create(params, user) do
    %__MODULE__{}
    |> changeset(params, user)
    |> Repo.insert()
  end

  def get(id) do
    __MODULE__
    |> preload(:user)
    |> Repo.get(id)
  end
end
