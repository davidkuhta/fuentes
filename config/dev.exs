use Mix.Config

config :fuentes, Fuentes.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "fuentes_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
