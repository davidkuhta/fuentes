defmodule Fuentes.Config do
  @moduledoc false
  @doc """
  Stores configuration variables used to communicate with Fuentes

  Returns the Fuentes Tenancy Setting. Set it in `mix.exs`:

      config :fuentes, tenancy: :true
  """
  #def tenancy, do: Application.get_env(:fuentes, :tenancy)
end
