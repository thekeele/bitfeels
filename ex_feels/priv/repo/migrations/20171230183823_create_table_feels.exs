defmodule ExFeels.Repo.Migrations.CreateTableFeels do
  use Ecto.Migration

  def change do
    create table("feels") do
      add :classifier, :string
      add :sentiment, :string
      add :tweet_id, references("tweets")

      timestamps()
    end
  end
end
