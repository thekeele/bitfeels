defmodule Bitfeels.Tweet.Parser do

  def parse_to_tweet(status) when is_map(status) do
    status
    |> Map.take(["created_at", "id","retweet_count", "favorite_count", "lang"])
    |> Map.put("text", parse_tweet_text(status))
    |> Map.put("hashtags", parse_hashtags(status))
    |> Map.put("user", parse_user(status))
  end

  defp parse_tweet_text(%{"extended_tweet" => %{"full_text" => text}}),
    do: text

  defp parse_tweet_text(%{"retweeted_status" => status}),
    do: status["extended_tweet"]["full_text"] || status["text"]

  defp parse_tweet_text(%{"quoted_status" => status}),
    do: status["extended_tweet"]["full_text"] || status["text"]

  defp parse_tweet_text(%{"text" => text}),
    do: text

  defp parse_hashtags(%{"entities" => %{"hashtags" => hashtags}}),
    do: Enum.map(hashtags, & &1["text"])

  defp parse_user(%{"user" => user}) do
    keys = [
      "id",
      "screen_name",
      "followers_count",
      "favourites_count",
      "time_zone",
      "verified",
      "statuses_count"
    ]

    Map.take(user, keys)
  end
end