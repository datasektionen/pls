defmodule Pls.Mixfile do
  use Mix.Project

  def project do
    [
      app: :pls,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Pls.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.12"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:httpoison, "~> 2.2"},
      {:poison, "~> 6.0"},
      {:cors_plug, "~> 3.0"},
      {:bandit, "~> 1.5"}
    ]
  end
end
