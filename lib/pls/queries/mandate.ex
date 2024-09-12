defmodule Pls.Queries.Mandate do
  import Ecto.Query

  def mandate(mandate) do
    from(m in Pls.Repo.Mandate,
      where: m.name == ^mandate,
      preload: :group
    )
    |> Pls.Repo.all()
    |> Enum.map(& &1.group.name)
  end

  def mandate(mandate, group_name) do
    mandate(mandate) |> Enum.member?(group_name)
  end

  def add_mandate(mandate, group_name) do
    Pls.Queries.insert(Pls.Repo.Mandate.new(group_name, mandate))
  end

  def delete_mandate(mandate, group_name) do
    group_id = Pls.Repo.one(from(g in Pls.Repo.Group, where: g.name == ^group_name, select: g.id))

    Pls.Queries.delete(
      from(p in Pls.Repo.Mandate,
        where: [group_id: ^group_id, name: ^mandate]
      )
    )
  end
end
