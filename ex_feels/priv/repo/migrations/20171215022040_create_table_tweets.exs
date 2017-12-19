defmodule ExFeels.Repo.Migrations.CreateTableTweets do
  use Ecto.Migration

  def change do
    create table("tweets") do
      add :text, :string
      add :retweet_count, :integer
      add :lang, :string
      add :tweet_id, :bigserial
      add :favorite_count, :integer
      add :created_at, :string
      add :hashtags, {:array, :string}

      timestamps()
    end

    unique_index("tweets", [:tweet_id])
  end
end