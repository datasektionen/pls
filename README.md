# Pls

## Database

To initialize the databse run the mix tasks
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

```
/user
/user/:uid
/user/:uid/:group               # Accepts POST/DELETE requests. an expiry date is required when posting.
/user/:uid/:group/:permission

/group
/group/:name                    # Accepts POST/DELETE requests
/group/:name/:permission        # Accepts POST/DELETE requests
```
