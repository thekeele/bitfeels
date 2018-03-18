defmodule ExFeelsWeb.StatsView do
  use ExFeelsWeb, :view

  def render("index.json", %{stats: stats}) do
    stats
    |> Enum.group_by(& &1.classifier)
    |> Enum.reduce([], fn classifier, classifiers ->
      [classifier_json(classifier) | classifiers]
    end)
  end

  defp classifier_json({classifier, data}) do
    %{
      name: classifier,
      data: Enum.map(data, &stat_json/1)
    }
  end

  defp stat_json(stat) do
    %{
      mean: stat.mean,
      std: stat.std,
      time: stat.time
    }
  end
end
