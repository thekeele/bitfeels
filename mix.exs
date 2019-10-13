defmodule Bitfeels.MixProject do
  use Mix.Project

  @version "2.2.1"

  def project do
    [
      app: :bitfeels,
      version: @version,
      elixir: "~> 1.9",
      package: package(),
      description: "How are we feeling today Bitcoin?",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "Bitfeels",
        source_ref: "v#{@version}",
        source_url: "https://github.com/thekeele/bitfeels"
      ]
    ]
  end

  def application do
    [
      mod: {Bitfeels.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:twitter_stream, "~> 0.2.4"},
      {:gen_stage, "~> 0.14"},
      {:hackney, "~> 1.14.3"},
      {:jason, "~> 1.1"},
      {:telemetry, "~> 0.4.0"}
    ]
  end

  defp package do
    %{
      licenses: [],
      maintainers: ["Mark Keele"],
      links: %{"GitHub" => "https://github.com/thekeele/bitfeels"}
    }
  end
end
