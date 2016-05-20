defmodule FuentesTest do
  #use ExUnit.Case, async: true

  #import ExUnit.CaptureIO

  #setup do
  #  :ok = Ecto.Adapters.SQL.Sandbox.checkout(Fuentes.TestRepo)
  #end

  use Fuentes.EctoCase

  doctest Fuentes
  doctest Fuentes.Account

  test "the truth" do
    assert 1 + 1 == 2
  end
end
