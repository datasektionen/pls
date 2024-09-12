import Config

config :pls,
  login_api_key: System.get_env("LOGIN_API_KEY"),
  login_host: System.get_env("LOGIN_HOST"),
  port: System.get_env("PORT") || 4000

config :pls, Pls.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "pls_dev",
  username: "postgres",
  password: "postgres",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  log_level: :info
