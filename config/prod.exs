use Mix.Config

config :fuentes, Fuentes.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: {:system, "DATABASE_URL"}
