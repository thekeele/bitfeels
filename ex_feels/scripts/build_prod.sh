# https://hexdocs.pm/phoenix/deployment.html

# kill the running process
kill $(ps aux | grep '[e]lixir' | awk '{print $2}')

# clean up
rm -rf ../_build
rm -rf ../assets/node_modules
rm -rf ../priv/static/

# compile app
cd ..
mix deps.get --only prod
MIX_ENV=prod mix compile

# compile assets
cd ./assets
npm install
brunch build --production

cd ..
MIX_ENV=prod mix phx.digest

# migrate db
MIX_ENV=prod mix ecto.migrate

# start server
MIX_ENV=prod PORT=4001 elixir --detached -S mix phx.server
