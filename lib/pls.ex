defmodule Pls do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Pls.Worker, [arg1, arg2, arg3]),
      supervisor(Pls.Repo, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Plss.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Pls.API do
  use Maru.Router

  before do
    plug Plug.Logger
    plug Plug.Static, at: "/", from: "static/"
    plug Plug.Parsers,
      pass: ["*/*"],
      json_decoder: Poison,
      parsers: [:urlencoded, :json, :multipart]

    plug Pls.Auth
  end

  namespace :api do
    mount Pls.API.User
    mount Pls.API.Group
  end

  rescue_from Pls.Auth.Unauthorized do
    conn
    |> put_status(401)
    |> text("Unauthorized")
  end

  rescue_from Maru.Exceptions.NotFound do
    conn
    |> put_status(404)
    |> text("Not Found")
  end

  rescue_from Maru.Exceptions.Validation do
    conn
    |> put_status(400)
    |> text("Bad request")
  end

  rescue_from Maru.Exceptions.InvalidFormatter do
    conn
    |> put_status(400)
    |> text("Bad request")
  end

  rescue_from Maru.Exceptions.MethodNotAllow do
    conn
    |> put_status(400)
    |> text("Bad request")
  end

end
