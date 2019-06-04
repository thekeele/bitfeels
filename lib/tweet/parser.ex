defmodule Bitfeels.Tweet.Parser do

  def parse_to_tweet(%{"extended_tweet" => %{"full_text" => text}} = status) do
    parse_tweet_data(status, text)
  end

  def parse_to_tweet(%{"retweeted_status" => status}) do
    text = status["extended_tweet"]["full_text"] || status["text"]

    parse_tweet_data(status, text)
  end

  def parse_to_tweet(%{"quoted_status" => status}) do
    text = status["extended_tweet"]["full_text"] || status["text"]

    parse_tweet_data(status, text)
  end

  def parse_to_tweet(%{"text" => text} = status) do
    parse_tweet_data(status, text)
  end

  defp parse_tweet_data(status, text) do
    status
    |> Map.take(["created_at", "id", "reply_count", "retweet_count", "favorite_count", "lang"])
    |> Map.put("text", text)
    |> Map.put("hashtags", parse_hashtags(status))
    |> Map.put("user", parse_user(status))
  end

  defp parse_hashtags(%{"entities" => %{"hashtags" => hashtags}}),
    do: Enum.map(hashtags, & &1["text"])

  defp parse_user(%{"user" => user}) do
    keys = [
      "id",
      "name",
      "verified",
      "screen_name",
      "profile_image_url",
      "statuses_count",
      "followers_count",
      "favourites_count",
      "location",
      "time_zone"
    ]

    Map.take(user, keys)
  end
end
