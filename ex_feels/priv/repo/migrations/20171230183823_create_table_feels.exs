defmodule ExFeels.Repo.Migrations.CreateTableFeels do
  use Ecto.Migration

  def change do
    create table("feels") do
      add :tweet_id, :bigserial
      add :classifier, :string
      add :sentiment, :string

      timestamps()
    end
  end
end
