defmodule Pls.Queries.Token do
  import Ecto.Query

  def add_token(tag, group_name) do
    rnd_str = Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)
    token = "#{tag}-#{rnd_str}"
    Pls.Queries.insert Pls.Repo.Token.new(group_name, tag, token)
  end

  def delete_token(tag, group_name) do
    group_id = Pls.Repo.one from(g in Pls.Repo.Group,
      where: g.name == ^group_name, select: g.id)

    Pls.Queries.delete from(p in Pls.Repo.Token,
      where: [group_id: ^group_id, tag: ^tag])
  end

  def get_token(token) do
    groups = from(t in Pls.Repo.Token,
      where: t.token == ^token,
      select: t.group_id)
    |> Pls.Repo.all

    from(g in Pls.Repo.Group,
      where: g.id in ^groups,
      preload: :permissions)
    |> Pls.Repo.all
    |> Enum.map(fn(group) ->
        {
          group.name |> String.split(".") |> List.first,
          group.permissions |> Enum.map(&(&1.name))
        }
      end)
    |> Enum.reduce(%{}, fn({name, permissions}, map) ->
        map |> Map.update(name, permissions, &Enum.uniq(Enum.concat &1, permissions))
      end)
  end

  def get_token(token, system) do
    get_token(token)
    |> Map.get(system, [])
  end

  def get_token(token, system, permission) do
    get_token(token, system)
    |> Enum.member?(permission)
  end

end
