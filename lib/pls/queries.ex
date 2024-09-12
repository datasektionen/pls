defmodule Pls.Queries do
  import Ecto.Query

  def insert(change) do
    case Pls.Repo.insert(change) do
      {:ok, struct} -> struct
      {:error, change} -> Ecto.Changeset.traverse_errors(change, fn {msg, _} -> msg end)
    end
  end

  def update(change) do
    case Pls.Repo.update(change) do
      {:ok, struct} -> struct
      {:error, change} -> Ecto.Changeset.traverse_errors(change, fn {msg, _} -> msg end)
    end
  end

  def delete(query) do
    case Pls.Repo.delete_all(query) do
      {res, nil} -> "Removed #{res} row(s)"
      {_, err} -> err
    end
  end

  def clean_memberships do
    delete(from(m in Pls.Repo.Membership, where: m.expiry < ^Date.utc_today()))
  end
end
