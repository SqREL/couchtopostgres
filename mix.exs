defmodule Couchtopostgres.Mixfile do
  use Mix.Project

  def project do
    [app: :couchtopostgres,
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
    [applications: [:logger, :httpoison, :postgrex, :ecto, :timex],
     mod: { Couchtopostgres, [] }]
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
    [
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 1.1.5"},
      {:httpoison, "0.8.2"},
      {:poison, "~> 1.0"},
      {:timex, "~> 2.1.1"},
      {:timex_ecto, "~> 1.0.3"}
    ]
  end
end
