use Mix.Config

config :pls,
  api_key: System.get_env("LOGIN_API_KEY") || nil,
  ecto_repos: [Pls.Repo]

config :pls, Pls.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL") || "postgres://addem:@localhost/pls"

config :maru, Pls.API,
  http: [port: System.get_env("PORT") || 5000]
