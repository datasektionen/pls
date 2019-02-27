defmodule Pls.Router do
  use Plug.Router

  if Mix.env == :dev do
    use Plug.Debugger, otp_app: :pls
  else
    plug Plug.SSL, rewrite_on: [:x_forwarded_proto]
  end

  plug Plug.Logger
  plug Plug.Static, at: "/", from: "static/"

  plug :match

  plug Plug.Parsers,
    pass: ["*/*"],
    json_decoder: Poison,
    parsers: [:urlencoded, :json, :multipart]

  plug CORSPlug

  plug Pls.Auth,
    login_api_key: Application.get_env(:pls, :login_api_key),
    login_host: Application.get_env(:pls, :login_host)

  plug :dispatch

  forward "/api/user", to: Pls.Router.User
  forward "/api/group", to: Pls.Router.Group
  forward "/api/mandate", to: Pls.Router.Mandate
  forward "/api/token", to: Pls.Router.Token

  get "/" do
    host = conn |> get_req_header("host")
    callback = URI.encode_www_form("#{conn.scheme}://#{host}/?token=")
    login_host = Application.get_env(:pls, :login_host)
    url  = "https://#{login_host}/login?callback=#{callback}"

    if conn.params |> Map.has_key?("token") do
      conn |> send_file(200, "static/index.html")
    else
      conn |> put_resp_header("location", url) |> send_resp(302, "")
    end
  end

  match _ do
    conn |> send_resp(404, "Not found")
  end
end
