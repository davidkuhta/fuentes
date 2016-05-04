#Mix.Task.run "ecto.create", ["quiet", "-r", "Fuentes.TestRepo"]
#Mix.Task.run "ecto.migrate", ["-r", "Fuentes.TestRepo"]

#Fuentes.TestRepo.start_link
ExUnit.start(capture_log: true)

Ecto.Adapters.SQL.Sandbox.mode(Fuentes.TestRepo, :manual)
