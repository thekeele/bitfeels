# https://hexdocs.pm/phoenix/deployment.html

# clean up
rm -rf ../_build
rm -rf ../assets/node_modules

# compile app
cd ..
mix deps.get --only prod
MIX_ENV=prod mix compile

# compile assets
cd ./assets
brunch build --production

cd ..
MIX_ENV=prod mix phx.digest

# migrate db
MIX_ENV=prod mix ecto.migrate

# start server
MIX_ENV=prod PORT=4001 elixir --detached -S mix phx.server
