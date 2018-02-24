defmodule ExFeelsWeb.StatsView do
  use ExFeelsWeb, :view

  def render("index.json", %{stats: stats}) do
    Enum.map(stats, &stats_json/1)
  end

  defp stats_json(stat) do
    %{
      classifier: stat.classifier,
      mean: stat.mean,
      std: stat.std,
      time: stat.time
    }
  end
end
