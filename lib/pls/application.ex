defmodule Pls.Application do
  use Application

  @impl true
  def start(_type, _args) do
    # Default port in case it's not set
    port = Application.get_env(:pls, :port, 4000)

    children = [
      Pls.Repo,
      {Bandit, scheme: :http, plug: Pls.Router, port: port}
    ]

    opts = [strategy: :one_for_one, name: Pls.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
