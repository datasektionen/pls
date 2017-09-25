defmodule Pls.Repo.Group do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Poison.Encoder, only: [:name]}
  schema "group" do
    field :name, :string

    many_to_many :members, Pls.Repo.User, join_through: Pls.Repo.Membership, on_delete: :delete_all

    has_many :permissions, Pls.Repo.Permission, on_delete: :delete_all
    has_many :memberships, Pls.Repo.Membership, on_delete: :delete_all
    has_many :mandates, Pls.Repo.Mandate, on_delete: :delete_all
    has_many :tokens, Pls.Repo.Token, on_delete: :delete_all
  end

  def new(name) do
    %Pls.Repo.Group{}
    |> cast(%{name: name}, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
