defmodule Pls.Repo.Migrations.MembershipIndex do
  use Ecto.Migration

  def change do
    create unique_index(:membership, [:user_id, :group_id])
  end
end
