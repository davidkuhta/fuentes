defmodule Mix.Tasks.Fuentes.Install do
  @moduledoc false
  use Mix.Task

  @shortdoc "Generates schema for double-entry accounting resources"

  @moduledoc """
    Generates a `setup_fuentes_tables` migration, which creates your accounts,
    entries, and amounts tables, as well as required indexes.
  """

  def run(_args) do
    source = Path.join(Application.app_dir(:fuentes, "/priv/templates/fuentes.install/"), "setup_fuentes_tables.exs")
    target = Path.join(Application.app_dir(:fuentes, "/priv/repo/migrations/"), "#{timestamp}_setup_fuentes_tables.exs")
    #IO.inspect File.cp_r(source, target)
    IO.inspect Mix.Generator.create_file(target, EEx.eval_file(source))
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: << ?0, ?0 + i >>
  defp pad(i), do: to_string(i)
end
