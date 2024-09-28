defmodule Pls.Router do
  use Plug.Router

  if Mix.env() == :dev do
    use Plug.Debugger, otp_app: :pls
  end

  plug Plug.Logger
  plug Plug.Static, at: "/", from: {:pls, "priv/static"}

  plug :match

  plug Plug.Parsers,
    pass: ["*/*"],
    json_decoder: Poison,
    parsers: [:urlencoded, :json, :multipart]

  plug CORSPlug

  plug Pls.Auth
  plug :dispatch

  forward "/api/user", to: Pls.Router.User
  forward "/api/group", to: Pls.Router.Group
  forward "/api/mandate", to: Pls.Router.Mandate
  forward "/api/token", to: Pls.Router.Token

  get "/" do
    host = conn |> get_req_header("host")
    callback = URI.encode_www_form("#{conn.scheme}://#{host}/?token=")
    login_url = Application.get_env(:pls, :login_frontend_url)
    url = "#{login_url}/login?callback=#{callback}"
    token = Plug.Conn.fetch_cookies(conn) |> Map.from_struct() |> get_in([:cookies, "token"])

    # If has cookie token or token in url
    # redirect to login
    if token != nil or Map.has_key?(conn.params, "token") do
      conn |> send_file(200, Application.app_dir(:pls) <> "/priv/static/index.html")
    else
      conn |> put_resp_header("location", url) |> send_resp(302, "")
    end
  end

  match _ do
    conn |> send_resp(404, "Not found")
  end
end
