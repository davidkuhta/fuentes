defmodule Mix.Tasks.Fuentes.Install do
  @moduledoc false
  use Mix.Task

  @shortdoc "Generates a schema for double-entry accounting resources"

  @moduledoc """
    Generates a `setup_fuentes_tables` migration, which creates your accounts,
    entries, and amounts tables, as well as required indexes.
  """

  def run(_args) do
    source = Path.join(Application.app_dir(:fuentes, "/priv/templates/fuentes.install/"), "setup_fuentes_tables.exs")
    target = Path.join(File.cwd!, "/priv/repo/migrations/#{timestamp}_setup_fuentes_tables.exs")

    if !File.dir?(target) do
      File.mkdir_p("priv/repo/migrations/")
    end

    Mix.Generator.create_file(target, EEx.eval_file(source))
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: << ?0, ?0 + i >>
  defp pad(i), do: to_string(i)
end
