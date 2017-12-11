defmodule ExFeelsWeb.Twitter.Crypto do
  # https://developer.twitter.com/en/docs/basics/authentication/guides/authorizing-a-request

  @consumer_key Application.get_env(:ex_feels, :twitter)[:consumer_key]
  @consumer_secret Application.get_env(:ex_feels, :twitter)[:consumer_secret]

  @access_token Application.get_env(:ex_feels, :twitter)[:access_token]
  @token_secret Application.get_env(:ex_feels, :twitter)[:token_secret]

  # oauth_consumer_key
  def consumer_key(),
    do: @consumer_key

  # oauth_token
  # https://developer.twitter.com/en/docs/basics/authentication/guides/access-tokens.html
  def token(),
    do: @access_token

  # oauth_signature_method
  def method(),
    do: "HMAC-SHA1"

  # oauth_timestamp
  def timestamp(),
    do: DateTime.utc_now() |> DateTime.to_unix()

  # oauth_nonce
  def nonce(bytes \\ 32) do
    string =
      bytes
      |> :crypto.strong_rand_bytes()
      |> Base.encode64(padding: false)

    Regex.replace(~r/\+|\/|[0-9]/, string, "z")
  end

  # oauth_version
  def version(),
    do: "1.0"

  def oauth_header(method, url) do
    ts = timestamp()
    nonce = nonce()

    sig =
      method
      |> signature_base_string(url, {ts, nonce})
      |> generate_signature()

    'OAuth oauth_consumer_key="#{consumer_key()}",oauth_token="#{token()}",oauth_signature_method="#{method()}",oauth_timestamp="#{ts}",oauth_nonce="#{nonce}",oauth_version="#{version()}",oauth_signature="#{sig}"'
  end

  defp signature_base_string(method, url, {ts, nonce}) do
    base =
      method <>
      "&#{URI.encode_www_form(url)}&"

    auth_params =
      "oauth_consumer_key=#{consumer_key()}" <>
      "&oauth_nonce=#{nonce}" <>
      "&oauth_signature_method=#{method()}" <>
      "&oauth_timestamp=#{ts}" <>
      "&oauth_token=#{token()}" <>
      "&oauth_version=#{version()}"
      |> URI.encode_www_form()

    base <> auth_params
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
end
