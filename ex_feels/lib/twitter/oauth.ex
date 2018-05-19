defmodule Twitter.OAuth do
  # https://developer.twitter.com/en/docs/basics/authentication/guides/authorizing-a-request

  def oauth_header(method, url, params \\ %{})
  def oauth_header(method, url, params) when is_atom(method),
    do: oauth_header(Atom.to_string(method), url, params)
  def oauth_header(method, url, params) when is_binary(method) do
    method = String.upcase(method)
    nonce = nonce()
    ts = timestamp()

    sig =
      {nonce, ts}
      |> signature_base_string(method, url, params)
      |> generate_signature()

    'OAuth oauth_consumer_key="#{consumer_key()}",oauth_token="#{token()}",oauth_signature_method="#{method()}",oauth_timestamp="#{ts}",oauth_nonce="#{nonce}",oauth_version="#{version()}",oauth_signature="#{sig}"'
  end

  defp signature_base_string({nonce, ts}, method, url, params) do
    base = method <> "&#{URI.encode_www_form(url)}&"
    params =
      %{
        "oauth_consumer_key" => consumer_key(),
        "oauth_nonce" => nonce,
        "oauth_signature_method" => method(),
        "oauth_timestamp" => ts,
        "oauth_token" => token(),
        "oauth_version" => version()
      }
      |> Map.merge(params)
      |> URI.encode_query()
      |> URI.encode_www_form()

    base <> params
  end

  # oauth_signature
  # https://developer.twitter.com/en/docs/basics/authentication/guides/creating-a-signature.html
  defp generate_signature(sig_base) do
    :sha
    |> :crypto.hmac(signing_key(), sig_base)
    |> :base64.encode()
    |> URI.encode_www_form()
  end

  defp signing_key() do
    customer_secret =
      System.get_env("TWITTER_CONSUMER_SECRET") || raise ":not_found $TWITTER_CONSUMER_SECRET"
    token_secret =
      System.get_env("TWITTER_TOKEN_SECRET") || raise ":not_found $TWITTER_TOKEN_SECRET"

    customer_secret <> "&" <> token_secret
  end

  # oauth_consumer_key
  defp consumer_key(),
    do: System.get_env("TWITTER_CONSUMER_KEY") || raise ":not_found $TWITTER_CONSUMER_KEY"

  # oauth_token
  # https://developer.twitter.com/en/docs/basics/authentication/guides/access-tokens.html
  defp token(),
    do: System.get_env("TWITTER_ACCESS_TOKEN") || raise ":not_found $TWITTER_ACCESS_TOKEN"

  # oauth_signature_method
  defp method(), do: "HMAC-SHA1"

  # oauth_timestamp
  defp timestamp(), do: DateTime.utc_now() |> DateTime.to_unix()

  # oauth_nonce
  defp nonce(bytes \\ 32) do
    random_encoded_binary =
      bytes
      |> :crypto.strong_rand_bytes()
      |> Base.encode64(padding: false)

    Regex.replace(~r/\+|\/|[0-9]/, random_encoded_binary, "z")
  end

  # oauth_version
  defp version(), do: "1.0"
end
