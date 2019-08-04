defmodule Bitfeels.Tweet.Parser do

  def parse_to_tweet(statuses) when is_list(statuses),
    do: Enum.map(statuses, &parse_to_tweet/1)

  def parse_to_tweet(%{"extended_tweet" => extended_tweet} = status) do
    status
    |> Map.take(["created_at", "reply_count", "retweet_count", "favorite_count", "lang"])
    |> Map.put("id", status["id"])
    |> Map.put("text", extended_tweet["full_text"])
    |> Map.put("type", "extended_tweet")
    |> Map.put("hashtags", parse_hashtags(extended_tweet))
    |> Map.put("user", parse_user(status))
  end

  def parse_to_tweet(%{"retweeted_status" => retweeted_status}) do
    text = retweeted_status["extended_tweet"]["full_text"] || retweeted_status["text"]

    retweeted_status
    |> Map.take(["created_at", "reply_count", "retweet_count", "favorite_count", "lang"])
    |> Map.put("id", retweeted_status["id"])
    |> Map.put("text", text)
    |> Map.put("type", "retweeted_status")
    |> Map.put("hashtags", parse_hashtags(retweeted_status))
    |> Map.put("user", parse_user(retweeted_status))
  end

  def parse_to_tweet(%{"quoted_status" => quoted_status}) do
    text = quoted_status["extended_tweet"]["full_text"] || quoted_status["text"]

    quoted_status
    |> Map.take(["created_at", "reply_count", "retweet_count", "favorite_count", "lang"])
    |> Map.put("id", quoted_status["id"])
    |> Map.put("text", text)
    |> Map.put("type", "quoted_status")
    |> Map.put("hashtags", parse_hashtags(quoted_status))
    |> Map.put("user", parse_user(quoted_status))
  end

  def parse_to_tweet(%{"text" => _} = status) do
    status
    |> Map.take([
      "text", "created_at", "reply_count", "retweet_count", "favorite_count", "lang"
    ])
    |> Map.put("id", status["id"])
    |> Map.put("type", "text")
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
