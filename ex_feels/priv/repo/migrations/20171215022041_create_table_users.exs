defmodule ExFeels.Repo.Migrations.CreateTableUsers do
  use Ecto.Migration

  def change do
    create table("users") do
      add :verified, :boolean, default: false
      add :time_zone, :string
      add :statuses_count, :integer
      add :screen_name, :string
      add :user_id, :bigserial
      add :followers_count, :integer
      add :favourites_count, :integer
      add :tweet_id, references("tweets")

      timestamps()
    end

    create index("users", [:user_id], unique: true)
  end
end
