defmodule ExFeels.Repo.Migrations.AlterTweetsModifyTextSize do
  use Ecto.Migration

  def change do
    alter table("tweets") do
      modify :text, :string, size: 300
    end
  end
end
