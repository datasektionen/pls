# Pls

## Database

To initialize the database run the mix tasks
```bash
mix ecto.create
mix ecto.migrate
```

To enter an interactive elixir shell and start the server run
```bash
iex -S mix
```


From there you can use the methods defined in Pls.Queries to edit the database. Most likely you would want to add these as a default, so that you can later use the frontend to make changes.

```bash
Pls.Queries.Group.add_permission "pls", "pls"
Pls.Queries.Mandate.add_mandate "d-sys@d.kth.se", "pls"
```

If you already have a server running you can run `iex -S mix pls` to open an interactive shell without starting another server.

## Endpoints
POST/DELETE always requires a valid login token

```
/                                   <-- Fancy admin frontend

/api/user
/api/user/:uid
/api/user/:uid/:group               # Accepts POST/DELETE requests. an expiry date is required when posting
/api/user/:uid/:group/:permission

/api/group
/api/group/:name                    # Accepts POST/DELETE requests
/api/group/:name/:permission        # Accepts POST/DELETE requests

/api/mandate/:name                  # Name is email as defined by dfunkt.
/api/mandate/:name/:group           # Accepts POST/DELETE

/api/token/:token/:system
/api/token/:token/:system/:permission

/api/token/:tag/:group              # Accepts POST/DELETE
```
