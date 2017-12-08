defmodule ExFeelsWeb.Twitter.Crypto do
  # https://developer.twitter.com/en/docs/basics/authentication/guides/authorizing-a-request

  # oauth_consumer_key
  def consumer_key(),
    do: Application.get_env(:ex_feels, :twitter)[:consumer_key]

  # oauth_nonce
  def nonce(bytes \\ 32) do
    string =
      bytes
      |> :crypto.strong_rand_bytes()
      |> Base.encode64(padding: false)

    Regex.replace(~r/\+|\/|[0-9]/, string, "z")
  end

  # oauth_signature
  # https://developer.twitter.com/en/docs/basics/authentication/guides/creating-a-signature.html
  def generate_signature(sig_base) do
    :sha
    |> :crypto.hmac(signing_key(), sig_base)
    |> :base64.encode()
  end

  # used to sign requests
  # https://developer.twitter.com/en/docs/basics/authentication/guides/creating-a-signature.html
  def signing_key() do
    customer = Application.get_env(:ex_feels, :twitter)[:consumer_secret]
    token = Application.get_env(:ex_feels, :twitter)[:token_secret]

    URI.encode_www_form(customer) <> "&" <> URI.encode_www_form(token)
  end

  # oauth_signature_method
  def method(),
    do: "HMAC-SHA1"

  # oauth_timestamp
  def timestamp(),
    do: DateTime.utc_now() |> DateTime.to_unix()

  # oauth_token
  # https://developer.twitter.com/en/docs/basics/authentication/guides/access-tokens.html
  def token(),
    do: Application.get_env(:ex_feels, :twitter)[:access_token]

  # oauth_version
  def version(),
    do: "1.0"
end
