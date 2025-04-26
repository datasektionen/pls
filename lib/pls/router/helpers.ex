defmodule Pls.Router.Helpers do
  import Plug.Conn

  def send_api_result(%Plug.Conn{private: %{resp_type: :json}} = conn, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(data))
  end

  def send_api_result(%Plug.Conn{private: %{resp_type: :jwt}} = conn, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, encode_jwt_claims(conn, data))
  end

  def encode_jwt_claims(
        %Plug.Conn{script_name: ["api" | rest], path_info: path_info},
        data
      ) do
    data =
      Enum.reverse(rest ++ path_info)
      |> Enum.reduce(data, fn
        "token", acc -> Map.put_new(%{}, "token", Map.values(acc) |> hd())
        label, acc -> Map.put_new(%{}, label, acc)
      end)

    token =
      Pls.Token.generate_and_sign!(%{
        "pls" => data,
        "iss" => Application.get_env(:pls, :endpoint)
      })

    %{"token" => token}
    |> Poison.encode!()
  end
end
