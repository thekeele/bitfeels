defmodule ExFeels.Twitter.User do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias ExFeels.{Twitter.Tweet, Repo}

  @fields [
    :verified, :time_zone, :statuses_count, :screen_name, :user_id,
    :followers_count, :favourites_count
  ]

  schema "users" do
    field :verified, :boolean, default: false
    field :time_zone, :string
    field :statuses_count, :integer
    field :screen_name, :string
    field :user_id, :integer
    field :followers_count, :integer
    field :favourites_count, :integer

    belongs_to :tweet, Tweet

    timestamps()
  end

  def changeset(struct \\ %__MODULE__{}, params \\ %{}) do
    params = Map.put(params, "user_id", params["id"])

    struct
    |> cast(params, @fields)
    |> unique_constraint(:user_id)
  end

  def create(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert()
  end

  def update(%__MODULE__{} = user, params) do
    user
    |> cast(params, [:verified, :time_zone, :statuses_count, :followers_count, :favourites_count])
    |> Repo.update()
  end

  def upsert(user_id, user_params) when is_integer(user_id) do
    case get(user_id) do
      nil ->
        create(user_params)

      user ->
        update(user, user_params)
    end
  end

  def get(user_id) do
    Repo.get_by(__MODULE__, user_id: user_id)
  end

  def count() do
    Repo.aggregate(__MODULE__, :count, :id)
  end
end
