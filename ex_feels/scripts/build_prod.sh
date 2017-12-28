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

# setup db
MIX_ENV=prod mix ecto.drop
MIX_ENV=prod mix ecto.create
MIX_ENV=prod mix ecto.migrate
