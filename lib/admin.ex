defmodule Pls.Admin do
  import Plug.Conn
  def init(options) do
    options
  end

  def call(conn, _opts) do
    IO.inspect conn

    host = get_req_header(conn, "host")
    callback = "#{conn.scheme}://#{host}/?token="
    url  = "https://login2.datasektionen.se/login?callback=#{URI.encode_www_form callback}"

    case {Dict.has_key?(conn.params, "token"), conn.path_info} do
      {true, []} -> conn |> send_file(200, "static/index.html")
      {false, []} -> conn |> put_resp_header("location", url) |> send_resp(302, "")
      _ -> conn
    end
  end
end
