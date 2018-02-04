defmodule ExFeels.Repo.Migrations.CreateTableStats do
  use Ecto.Migration

  def change do
    create table("stats") do
      add :classifier, :string
      add :mean, :float
      add :std, :float
      add :time, :string
    end
  end
end
