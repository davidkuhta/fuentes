Mix.Task.run "ecto.create", ["quiet", "-r", "Fuentes.TestRepo"]
Mix.Task.run "ecto.migrate", ["-r", "Fuentes.TestRepo"]

#Fuentes.TestRepo.start_link
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Fuentes.TestRepo, :manual)
