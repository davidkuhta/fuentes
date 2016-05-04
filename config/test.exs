use Mix.Config

config :fuentes, Fuentes.TestRepo,
  hostname: "localhost",
  database: "fuentes_test",
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :warn

config :fuentes, ecto_repos: [Fuentes.TestRepo]
