import Config

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  port = System.get_env("PORT") || raise "PORT is missing"

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :pls, Pls.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  login_api_key = System.get_env("LOGIN_API_KEY") || raise "LOGIN_API_KEY is missing"
  login_api_url = System.get_env("LOGIN_API_URL") || raise "LOGIN_API_URL is missing"

  login_frontend_url =
    System.get_env("LOGIN_FRONTEND_URL") || raise "LOGIN_FRONTEND_URL is missing"

  config :pls,
    login_api_key: login_api_key,
    login_api_url: login_api_url,
    login_frontend_url: login_frontend_url,
    port: port

  # Honestly I don't know if this does anything
  config :pls, Pls.Router,
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ]
end
