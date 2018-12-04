defmodule Pls.Repo.Migrations.TokenUsage do
  use Ecto.Migration

  def change do
    alter table(:token) do
      add :accessed, :utc_datetime
    end
  end
end
