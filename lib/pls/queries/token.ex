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

end
