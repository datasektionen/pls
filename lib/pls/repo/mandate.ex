defmodule Pls.Repo.Mandate do
  use Ecto.Schema
  import Ecto.Query

  @derive {Poison.Encoder, only: [:name]}
  schema "mandate" do
    belongs_to :group, Pls.Repo.Group

    field :name, :string
  end

  def new(group_name, mandate) do
    group = Pls.Repo.one from(g in Pls.Repo.Group, where: g.name == ^group_name)
    group = group || Pls.Queries.Group.add_group group_name

    Ecto.build_assoc(group, :mandates, %{name: mandate})
  end
end

