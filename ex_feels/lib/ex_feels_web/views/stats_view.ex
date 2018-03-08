defmodule ExFeelsWeb.StatsView do
  use ExFeelsWeb, :view

  def render("index.json", %{stats: stats}) do
    stats
    |> Enum.map(&stats_json/1)
    |> Enum.sort(& &1.time <= &2.time)
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
