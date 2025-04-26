import Config

pem_cert =
  case System.get_env("PEM_CERT") do
    nil ->
      # Generate a new key if we don't have one
      privkey = :public_key.generate_key({:rsa, 2048, 65537})

      :public_key.pem_encode([:public_key.pem_entry_encode(:RSAPrivateKey, privkey)])
      |> Base.encode64()

    key ->
      key
  end
  |> Base.decode64!()

config :pls,
  login_api_key: System.get_env("LOGIN_API_KEY"),
  login_api_url: System.get_env("LOGIN_API_URL"),
  login_frontend_url: System.get_env("LOGIN_FRONTEND_URL"),
  endpoint: System.get_env("ENDPOINT") || "http://localhost:4000",
  port: System.get_env("PORT") || 4000

config :joken,
  default_key: [
    signer_alg: "RS256",
    key_pem: pem_cert
  ]

database_url = System.get_env("DATABASE_URL", "ecto://postgres:postgres@localhost/pls_dev")

config :pls, Pls.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: database_url,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  log_level: :info
