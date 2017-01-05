# Pls

## Database

To initialize the database run the mix tasks
```bash
mix ecto.create
mix ecto.migrate
```

To enter an interactive elixir shell run
```bash
iex -S mix
```

From there you can use the methods defined in Pls.Queries to edit the database.

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
```
