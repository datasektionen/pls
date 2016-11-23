defmodule Pls.Admin do
  import Plug.Conn
  def init(options) do
    options
  end

  def call(conn, _opts) do
    host = get_req_header(conn, "host")
    callback = "#{conn.scheme}://#{host}/?token="
    url  = "https://login2.datasektionen.se/login?callback=#{URI.encode_www_form callback}"

    valid_token = case Pls.Auth.is_enabled? do
      true -> Dict.has_key?(conn.params, "token") && Pls.Auth.get_user(conn.params["token"])
      false -> true
    end

    case {valid_token, conn.path_info} do
      {false, []} -> conn |> put_resp_header("location", url) |> send_resp(302, "")
      {_,     []} -> conn |> send_file(200, "static/index.html")
      {_,     _ } -> conn
    end
  end
end
