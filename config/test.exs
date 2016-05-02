use Mix.Config

config :fuentes, Fuentes.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "fuentes_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
