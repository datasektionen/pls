defmodule Pls.Repo.Permission do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  @derive {Poison.Encoder, only: [:name]}
  schema "permission" do
    belongs_to :group, Pls.Repo.Group

    field :name, :string
  end

  def new(group_name, permission) do
    group = Pls.Repo.one from(g in Pls.Repo.Group, where: g.name == ^group_name)
    group = group || Pls.Queries.Group.add_group group_name
    
    Ecto.build_assoc(group, :permissions)
    |> cast(%{name: permission}, [:name])
    |> unique_constraint(:name, name: :permission_name_group_id_index)
  end
end

