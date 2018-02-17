defmodule ExFeels.Repo.Migrations.CreateTableStats do
  use Ecto.Migration

  def change do
    create table("stats") do
      add :classifier, :string
      add :mean, :real
      add :std, :real
      add :time, :string
    end
  end
end
