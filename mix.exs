defmodule Fuentes.Mixfile do
  use Mix.Project

  @version "0.0.1"
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
    [applications: [:postgrex, :ecto, :logger]]#,
      #mod: {Fuentes, []}]
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
      links: %{"GitHub" => "https://github.com/davidkuhta/fuentes"},
      files: ~w(mix.exs README.md CHANGELOG.md lib) #++
            #~w(integration_test/cases integration_test/sql integration_test/support)
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      #{}"test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp elixirc_paths(:test), do: elixirc_paths ++ ["test/support"]
  defp elixirc_paths(_), do: elixirc_paths
  defp elixirc_paths, do: ["lib"]
end
