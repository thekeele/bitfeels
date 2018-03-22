defmodule ExFeels.Repo.Migrations.AlterStatsModifyTimeInteger do
  use Ecto.Migration

  def up do
    execute("DELETE FROM stats;")

    alter table("stats") do
      remove :time

      add :time, :integer
    end
  end

  def down do
    execute("DELETE FROM stats;")

    alter table("stats") do
      remove :time

      add :time, :string
    end
  end
end
