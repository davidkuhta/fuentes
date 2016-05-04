defmodule Fuentes.EctoCase do
  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Fuentes.TestRepo)
  end
end
