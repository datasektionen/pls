defmodule Pls.Repo.Migrations.MandateMembers do
  use Ecto.Migration

  def change do
    create table(:mandate_member) do
      add :group_id, references(:group, on_delete: :delete_all)
      add :name, :string
    end
  end
end
