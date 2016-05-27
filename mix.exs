defmodule Fuentes.Mixfile do
  use Mix.Project

  @version "0.0.2"
  def project do
    [app: :fuentes,
     version: @version,
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     aliases: aliases,

     # Hex
     description: description,
     package: package,

     # Docs
     name: "Fuentes",
     docs: [source_ref: "v#{@version}", main: "Fuentes",
            canonical: "",
            source_url: "https://github.com/davidkuhta/fuentes"]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:postgrex, :ecto, :logger]]
  end

  defp deps do
    [
      {:ecto, "~> 2.0.0-rc.5"},
      {:postgrex, ">= 0.0.0"},
      {:ex_machina, git: "https://github.com/thoughtbot/ex_machina", branch: "master", only: :test},
      {:earmark, ">= 0.0.0", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end

  defp description do
    """
    Fuentes is a library which provides a double-entry accounting system for your Elixir application.
    """
  end

  defp package do
    [
      maintainers: ["David Kuhta"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/davidkuhta/fuentes"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"]
    ]
  end

  defp elixirc_paths(:test), do: elixirc_paths ++ ["test/support"]
  defp elixirc_paths(_), do: elixirc_paths
  defp elixirc_paths, do: ["lib"]
end
