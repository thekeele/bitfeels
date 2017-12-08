defmodule ExFeelsWeb.Twitter do

  alias ExFeelsWeb.Twitter.Crypto

  def request(method \\ "GET", base_url \\ "https://api.twitter.com/1.1/account/settings.json") do
    params = collect_parameters()
    sig_base = sig_base_string(method, base_url, params)
    sig = Crypto.generate_signature(sig_base)

    headers = [
      {"Authorization", "OAuth #{build_header(sig)}"}
    ]

    case :hackney.request(:get, base_url, headers, [], [:with_body]) do
      anything ->
        IO.inspect anything
    end
  end

  defp collect_parameters() do
    "oauth_consumer_key=#{Crypto.consumer_key()}" <>
    "&oauth_nonce=#{Crypto.nonce()}" <>
    "&oauth_signature_method=#{Crypto.method()}" <>
    "&oauth_timestamp=#{Crypto.timestamp()}" <>
    "&oauth_token=#{Crypto.token()}" <>
    "&oauth_version=#{Crypto.version()}"
    |> URI.encode_www_form()
  end

  defp sig_base_string(method, base_url, params) do
    method <>
    "&#{URI.encode_www_form(base_url)}" <>
    "&#{params}"
  end

  defp build_header(sig) do
    "oauth_consumer_key=#{Crypto.consumer_key()}" <>
    ", oauth_nonce=#{Crypto.nonce()}" <>
    ", oauth_signature=#{URI.encode_www_form(sig)}" <>
    ", oauth_signature_method=#{Crypto.method()}" <>
    ", oauth_timestamp=#{Crypto.timestamp()}" <>
    ", oauth_token=#{Crypto.token()}" <>
    ", oauth_version=#{Crypto.version()}"
  end
end
