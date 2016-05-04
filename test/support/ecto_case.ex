defmodule Fuentes.EctoCase do
  use ExUnit.CaseTemplate

  #setup do
  #  :ok = Ecto.Adapters.SQL.Sandbox.checkout(Fuentes.TestRepo)
  #end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Fuentes.TestRepo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Fuentes.TestRepo, {:shared, self()})
    end
  end
end
