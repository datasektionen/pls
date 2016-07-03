defmodule Pls.Auth do
  import Plug.Conn
  import HTTPotion

  defmodule Unauthorized do
    defexception message: "Authentication failed"
  end

  def init(options) do
    options
  end
  
  def call(conn, _opts) do
    case {Application.get_env(:pls, :api_key), conn.method} do
      {nil, _}     -> conn
      {_, "GET"}   -> conn
      {api_key, _} -> conn |> authenticate(api_key)
    end
  end

  def authenticate(conn, api_key) do
    if not Dict.has_key?(conn.query_params, "token"), do: raise Unauthorized

    url = "https://login2.datasektionen.se/verify/" <> conn.query_params["token"]
    res = get(url, query: %{api_key: api_key, format: "json"})

    if res.status_code != 200, do: raise Unauthorized

    {:ok, json} = Poison.decode(res.body)

    user = json["user"]

    group = case conn.path_info do
      ["api", "user", _, group]  -> group
      ["api", "group", group]    -> group
      ["api", "group", group, _] -> group
    end

    unless is_admin?(user, group),  do: raise Unauthorized

    conn
  end

  def is_admin?(user, group) do
    Pls.Queries.user(user, "pls") or Pls.Queries.user(user, "pls." <> group)
  end
end
