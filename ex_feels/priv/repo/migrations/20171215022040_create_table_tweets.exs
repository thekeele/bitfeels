defmodule ExFeels.Repo.Migrations.CreateTableTweets do
  use Ecto.Migration

  def change do
    create table("tweets") do
      add :text, :string
      add :retweet_count, :integer
      add :lang, :string
      add :tweet_id, :integer
      add :favorite_count, :integer
      add :created_at, :naive_datetime
      add :hashtags, {:array, :string}

      timestamps()
    end
  end
end
