import Config

config :pls,
  ecto_repos: [Pls.Repo]


import_config "#{config_env()}.exs"
