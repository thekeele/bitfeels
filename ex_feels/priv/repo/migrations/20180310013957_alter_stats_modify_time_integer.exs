defmodule ExFeels.Repo.Migrations.AlterStatsModifyTimeInteger do
  use Ecto.Migration

  def change do
    alter table("stats") do
      modify :time, :integer
    end
  end
end
