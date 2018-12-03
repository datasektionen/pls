defmodule Pls.Mixfile do
  use Mix.Project

  def project do
    [
      app: :pls,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Pls, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto,      "~> 2.2"},
      {:postgrex,  ">= 0.0.0"},
      {:httpoison, "~> 0.13"},
      {:poison,    "~> 3.1"},
      {:cors_plug, "~> 1.1"},
      {:cowboy,    "~> 1.1"},
      {:plug_cowboy, "~> 1.0"}
    ]
  end
end
