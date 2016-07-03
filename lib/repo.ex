defmodule Pls.Repo do
  use Ecto.Repo,
    otp_app: :pls
end

defmodule Pls.Repo.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Poison.Encoder, only: [:uid]}
  schema "user" do
    field :uid, :string
    
    many_to_many :groups, Pls.Repo.Group, join_through: Pls.Repo.Membership, on_delete: :delete_all
  end

  def new(uid) do
    %Pls.Repo.User{}
    |> cast(%{uid: uid}, [:uid])
    |> validate_required([:uid])
    |> unique_constraint(:uid)
  end
end

defmodule Pls.Repo.Group do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Poison.Encoder, only: [:name]}
  schema "group" do
    field :name, :string
    
    has_many :permissions, Pls.Repo.Permission, on_delete: :delete_all
    has_many :collections, Pls.Repo.Collection, on_delete: :delete_all
    
    many_to_many :members, Pls.Repo.User, join_through: Pls.Repo.Membership, on_delete: :delete_all
  end

  def new(name) do
    %Pls.Repo.Group{}
    |> cast(%{name: name}, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end

defmodule Pls.Repo.Membership do
  use Ecto.Schema
  import Ecto.Query

  @derive {Poison.Encoder, only: [:expiry]}
  schema "membership" do
    belongs_to :group, Pls.Repo.Group
    belongs_to :user, Pls.Repo.User
    
    field :expiry, Ecto.Date
  end

  def new(user, group, expiry) do
    user = Pls.Repo.one from(u in Pls.Repo.User, where: u.uid == ^user)
    group = Pls.Repo.one from(g in Pls.Repo.Group, where: g.name == ^group)
    %Pls.Repo.Membership{
      user: user,
      group: group,
      expiry: Ecto.Date.cast!(expiry)
    }
  end
end

defmodule Pls.Repo.Permission do
  use Ecto.Schema
  import Ecto.Query

  @derive {Poison.Encoder, only: [:name]}
  schema "permission" do
    belongs_to :group, Pls.Repo.Group
    
    field :name, :string
  end

  def new(group_name, permission) do
    from(g in Pls.Repo.Group, where: g.name == ^group_name)
    |> Pls.Repo.one
    |> Ecto.build_assoc(:permissions, %{name: permission})
  end

end

defmodule Pls.Repo.Collection do
  use Ecto.Schema
  import Ecto.Query

  @derive {Poison.Encoder, only: [:name]}
  schema "collection" do
    belongs_to :group, Pls.Repo.Group
    
    field :name, :string
  end

  def new(collection, group_name) do
    from(g in Pls.Repo.Group, where: g.name == ^group_name)
    |> Pls.Repo.one
    |> Ecto.build_assoc(:collections, %{name: collection})
  end

end
