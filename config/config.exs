use Mix.Config

config :bitfeels, Bitfeels.Application,
  twitter_stream: %{"track" => "bitcoin"},
  tweet_pipeline: [max_demand: 10, min_demand: 3]

config :bitfeels, Bitfeels.Repo,
  database: "bitfeels",
  hostname: "localhost"

config :bitfeels,
  ecto_repos: [Bitfeels.Repo]


