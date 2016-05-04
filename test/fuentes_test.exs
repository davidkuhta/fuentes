defmodule FuentesTest do
  use Fuentes.EctoCase
  alias Fuentes.TestRepo
  
  doctest Fuentes
  doctest Fuentes.Account

  test "the truth" do
    assert 1 + 1 == 2
  end
end
