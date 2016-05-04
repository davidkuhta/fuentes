defmodule Fuentes.TestRepo.Migrations.AddEntriesTable do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :description, :string, null: false
      add :date, :date, null: false

      timestamps
    end

    create index(:entries, [:date])
  end
end
