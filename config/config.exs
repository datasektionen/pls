use Mix.Config

config :pls,
  login_api_key: System.get_env("LOGIN_API_KEY"),
  login_host: System.get_env("LOGIN_HOST"),
  ecto_repos: [Pls.Repo]

config :pls, Pls.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL") || "postgres://postgres@localhost/postgres"
