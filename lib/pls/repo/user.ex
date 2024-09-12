defmodule Pls.Repo.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Poison.Encoder, only: [:uid]}
  schema "user" do
    field :uid, :string

    # many_to_many :groups, Pls.Repo.Group, join_through: Pls.Repo.Membership, on_delete: :delete_all
  end

  def new(uid) do
    %Pls.Repo.User{}
    |> cast(%{uid: uid}, [:uid])
    |> validate_required([:uid])
    |> unique_constraint(:uid)
  end
end
