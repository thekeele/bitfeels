defmodule Bitfeels.MixProject do
  use Mix.Project

<<<<<<< HEAD
  @version "2.0.0"
=======
  @version "2.0.1"
>>>>>>> release/v2.0.1

  def project do
    [
      app: :bitfeels,
      version: @version,
      elixir: "~> 1.7",
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
<<<<<<< HEAD
      {:twitter_stream, git: "git@github.com:thekeele/twitter_stream.git", tag: "v0.2.1"},
=======
      {:twitter_stream, github: "thekeele/twitter_stream", tag: "v0.2.1"},
>>>>>>> release/v2.0.1
      {:gen_stage, "~> 0.14"},
      {:hackney, "~> 1.14.3"},
      {:jason, "~> 1.1"},
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
