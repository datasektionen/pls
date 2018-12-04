defmodule Pls.Queries.Group do
  import Ecto.Query

  def group do
    Pls.Repo.all from(g in Pls.Repo.Group, select: g.name)
  end

  def group(name) do
    group = from(g in Pls.Repo.Group,
      where: g.name == ^name,
      preload: [:permissions, :mandates, :memberships, :tokens])
    |> Pls.Repo.one

    if group == nil do
      {:error, :no_such_group}
    else
      %{memberships: group.memberships,
        permissions: Enum.map(group.permissions, &(&1.name)),
        mandates: Enum.map(group.mandates, &(&1.name)),
        tags: Enum.map(group.tokens, &(%{tag: &1.tag, accessed: &1.accessed}))}
    end
  end

  def group(name, permission) do
    Enum.member? group(name).permissions, permission
  end

  def add_group(name) do
    Pls.Queries.insert Pls.Repo.Group.new(URI.decode name)
  end

  def delete_group(name) do
    Pls.Queries.delete from(g in Pls.Repo.Group,
      where: g.name == ^name)
  end

  def add_permission(group_name, permissions) when is_list(permissions) do
    Enum.map(permissions, fn(permission) -> add_permission(group_name, permission) end)
  end

  def add_permission(group_name, permission) do
    Pls.Queries.insert Pls.Repo.Permission.new(group_name, permission)
  end

  def delete_permission(group_name, permission) do
    group_id = Pls.Repo.one from(g in Pls.Repo.Group,
      where: g.name == ^group_name, select: g.id)

    Pls.Queries.delete from(p in Pls.Repo.Permission,
      where: [group_id: ^group_id, name: ^permission])
  end

end
