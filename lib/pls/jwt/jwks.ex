defmodule Pls.Jwt.Jwks do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    %{jwk: jwk} = Joken.Signer.parse_config()
    {_, jwk} = JOSE.JWK.to_public_map(jwk)

    jwk = Map.put(jwk, "kid", "schmunguss")

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{"keys" => [jwk]}))
  end
end
