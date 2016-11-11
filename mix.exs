defmodule Pls.Mixfile do
  use Mix.Project

  def project do
    [app: :pls,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    dev_apps = case Mix.env do
      :dev -> [:exsync]
      _ -> []
    end
    [applications: dev_apps ++ [:logger, :httpotion, :postgrex, :ecto, :maru],
     mod: {Pls, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:maru,      "~> 0.10"},
     {:ecto,      "~> 2.0.0"},
     {:postgrex,  ">= 0.0.0"},
     {:httpotion, "~> 3.0.0"},
     {:poison,    "~> 1.5"},
     {:exsync,    "~> 0.1", only: :dev},
     {:cors_plug, "~> 1.1"}]
  end
end
