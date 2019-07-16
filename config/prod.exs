use Mix.Config

config :bitfeels, :sentiment,
  url: "http://senpytweet:5000/score",
  model: "spacy"
