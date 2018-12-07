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
      extra_applications: [:logger],
      mod: {Bitfeels.Application, []}
    ]
  end

  defp deps do
    [
      {:twitter_stream, git: "git@github.com:thekeele/twitter_stream.git", tag: "v0.1.1"},
      {:gen_stage, "~> 0.14"},
      {:hackney, "~> 1.14.3"},
      {:jason, "~> 1.1"},
    ]
  end
end
