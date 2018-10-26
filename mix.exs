defmodule Bitfeels.MixProject do
  use Mix.Project

  def project do
    [
      app: :bitfeels,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :twitter_stream],
      mod: {Bitfeels.Application, []}
    ]
  end

  defp deps do
    [
      {:twitter_stream, path: "../twitter_stream"}
    ]
  end
end
