use Mix.Config

config :bitfeels, Bitfeels.Repo,
  database: "bitfeels",
  hostname: "localhost"

config :bitfeels,
  ecto_repos: [Bitfeels.Repo]

config :bitfeels, Bitfeels.Application,
  twitter_stream: %{"track" => "bitcoin"},
  source_counter: 0,
  tweet_pipeline: [max_demand: 5, min_demand: 2]
