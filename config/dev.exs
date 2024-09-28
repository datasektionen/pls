import Config

config :pls,
  login_api_key: System.get_env("LOGIN_API_KEY"),
  login_api_url: System.get_env("LOGIN_API_URL"),
  login_frontend_url: System.get_env("LOGIN_FRONTEND_URL"),
  port: System.get_env("PORT") || 4000

database_url = System.get_env("DATABASE_URL", "ecto://postgres:postgres@localhost/pls_dev")

config :pls, Pls.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: database_url,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  log_level: :info
