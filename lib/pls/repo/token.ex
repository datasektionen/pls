defmodule Pls.Repo.Token do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  @derive {Poison.Encoder, only: [:tag, :token]}
  schema "token" do
    belongs_to :group, Pls.Repo.Group

    field :tag, :string
    field :token, :string
  end

  def new(group_name, tag, token) do
    group = Pls.Repo.one from(g in Pls.Repo.Group, where: g.name == ^group_name)
    group = group || Pls.Queries.Group.add_group group_name

    Ecto.build_assoc(group, :tokens)
    |> cast(%{tag: tag, token: token}, [:tag, :token])
    |> unique_constraint(:name, name: :token_tag_group_id_index)
  end
end
