defmodule Bitfeels do
  def tweet_store() do
    :ets.info(:tweet_store)
  end
end
