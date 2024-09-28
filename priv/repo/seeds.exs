# Seed file to create a working database
alias Pls.Queries

Queries.Group.add_permission("pls", "pls")

%{memberships: memberships} = Queries.Group.group("pls")

if !Enum.any?(memberships, fn m -> m.uid == "turetek" end) do
  Queries.User.add_membership(
    "turetek",
    "pls",
    Date.utc_today() |> Date.add(365)
  )
end
