# Pls

## Setup (Docker)

Easiest way to run the project is to use Docker. Assuming you have
`docker` and `docker-compose` installed, you can run the following
commands.

```bash
docker-compose build
docker-compose up
```

This sets up a database, a local login instance, and a Pls instance.
Then you can access the server at `http://localhost:4000`.

## Setup (Local)

Without docker you will need a separate postgres database and
an up-to-date [elixir installation](https://elixir-lang.org/install.html).
You will also need a valid API key to [login](https://github.com/datasektionen/login), or run your own instance of [nyckeln-under-dörrmattan](https://github.com/datasektionen/nyckeln-under-dorrmattan).

## Database

To initialize the database run the mix tasks

```bash
mix ecto.create
mix ecto.migrate
# Optional: seed the database with some test data
mix run priv/repo/seeds.exs
```

## Server

To start the server run

```bash
mix run --no-halt
```

To enter an interactive elixir shell and start the server run

```bash
iex -S mix
```

From there you can use the methods defined in Pls.Queries to edit the
database. There are some hard-coded permissions that you need to have
in order to make changes to the database.

Most likely you would want to add these as a default, so
that you can later use the frontend to make changes. Replace
`<kth-id>` with your kth-id.

```elixir
Pls.Queries.Group.add_permission("pls", "pls")
Pls.Queries.User.add_membership("<kth-id>", "pls", "2050-01-01")
```

## Endpoints

POST/DELETE always requires a valid login token as part of the request
body. The token needs to be a valid active token from login.

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

## Dependencies

This service depends on [login](https://github.com/datasektionen/login)
and [dfunkt](https://github.com/datasektionen/dfunkt/).
