defmodule Pls.Jwt.OpenId do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    data = %{
      "issuer" => Application.get_env(:pls, :endpoint),
      "jwks_uri" => "#{Application.get_env(:pls, :endpoint)}/.well-known/jwks.json"
    }

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(data))
  end
end
