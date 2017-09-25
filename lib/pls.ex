defmodule Pls do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Pls.Repo,
      {
        Plug.Adapters.Cowboy,
        scheme: :http,
        plug: Pls.Router,
        options: [port: case Integer.parse(System.get_env("PORT")) do
                          {p, _} -> p
                          _ -> 5000
                        end]
      }
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pls.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

