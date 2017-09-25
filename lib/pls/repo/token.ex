defmodule Pls.Repo.Token do
  use Ecto.Schema
  import Ecto.Query

  @derive {Poison.Encoder, only: [:tag]}
  schema "token" do
    belongs_to :group, Pls.Repo.Group

    field :tag, :string
    field :token, :string
  end

  def new(group_name, tag, token) do
    group = Pls.Repo.one from(g in Pls.Repo.Group, where: g.name == ^group_name)
    group = group || Pls.Queries.Group.add_group group_name

    Ecto.build_assoc(group, :tokens, %{tag: tag, token: token})
  end
end
