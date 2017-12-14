defmodule ExFeelsWeb.Twitter.Crypto do
  # https://developer.twitter.com/en/docs/basics/authentication/guides/authorizing-a-request

  @consumer_key Application.get_env(:ex_feels, :twitter)[:consumer_key]
  @consumer_secret Application.get_env(:ex_feels, :twitter)[:consumer_secret]

  @access_token Application.get_env(:ex_feels, :twitter)[:access_token]
  @token_secret Application.get_env(:ex_feels, :twitter)[:token_secret]

  def oauth_header(method, url, params) do
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
    customer_secret = @consumer_secret
    token_secret = @token_secret

    customer_secret <> "&" <> token_secret
  end

  # oauth_consumer_key
  defp consumer_key(),
    do: @consumer_key

  # oauth_token
  # https://developer.twitter.com/en/docs/basics/authentication/guides/access-tokens.html
  defp token(),
    do: @access_token

  # oauth_signature_method
  defp method(),
    do: "HMAC-SHA1"

  # oauth_timestamp
  defp timestamp(),
    do: DateTime.utc_now() |> DateTime.to_unix()

  # oauth_nonce
  defp nonce(bytes \\ 32) do
    string =
      bytes
      |> :crypto.strong_rand_bytes()
      |> Base.encode64(padding: false)

    Regex.replace(~r/\+|\/|[0-9]/, string, "z")
  end

  # oauth_version
  defp version(),
    do: "1.0"
end
