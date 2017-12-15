defmodule ExFeels.Twitter.User do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias ExFeels.{Twitter.Tweet, Repo}

  @fields [
    :verified, :time_zone, :status_count, :screen_name, :user_id,
    :followers_count, :favourites_count
  ]

  schema "users" do
    field :verified, :boolean, default: false
    field :time_zone, :string
    field :status_count, :integer
    field :screen_name, :string
    field :user_id, :integer
    field :followers_count, :integer
    field :favourites_count, :integer

    belongs_to :tweet, Tweet

    timestamps()
  end

  def changeset(struct \\ %__MODULE__{}, params \\ %{}) do
    cast(struct, params, @fields)
  end

  def create(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert()
  end

  def get(id) do
    Repo.get(__MODULE__, id)
  end
end
