# Seed file to create a working database
alias Pls.Queries

Queries.Group.add_permission("pls", "pls")

Queries.User.add_membership(
  "turetek",
  "pls",
  Date.utc_today() |> Date.add(365)
)
