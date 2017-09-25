defmodule Pls.Queries.Token do
  import Ecto.Query

  def token(token) do
    from(m in Pls.Repo.Token,
      where: m.token == ^token,
      preload: [group: :permissions])
    |> Pls.Repo.all
    |> Enum.map(fn(x) ->
        {
          x.group.name |> String.split(".") |> List.first,
          x.group.permissions |> Enum.map(&(&1.name))
        }
      end)
    |> Enum.reduce(%{}, fn({name, permissions}, map) ->
        map |> Map.update(name, permissions, &Enum.uniq(Enum.concat &1, permissions))
      end)
  end

  def token(token, system) do
    token(token) |> Map.get(system)
  end

  def token(token, system, permission) do
    token(token, system) |> Enum.member?(permission)
  end

  def add_token(tag, group_name) do
    rnd_str = Base.url_encode64(:crypto.strong_rand_bytes(64), padding: false)
    token = "#{tag}-#{rnd_str}"
    Pls.Queries.insert Pls.Repo.Token.new(group_name, tag, token)
    %{token: token, tag: tag}
  end

  def delete_token(tag, group_name) do
    group_id = Pls.Repo.one from(g in Pls.Repo.Group,
      where: g.name == ^group_name, select: g.id)

    Pls.Queries.delete from(p in Pls.Repo.Token,
      where: [group_id: ^group_id, tag: ^tag])
  end

end
