defmodule Pls.Auth do
  import Plug.Conn
  import HTTPotion

  defmodule Unauthorized do
    defexception message: "Authentication failed"
  end

  def init(options) do
    if Application.get_env(:pls, :api_key) in ["", nil] do
      [:red, "Environment variable LOGIN_API_KEY is missing"] |> IO.ANSI.format |> IO.puts
    end

    options
  end
  
  def call(conn, _opts) do
    case {Application.get_env(:pls, :api_key), conn.method} do
      {_, "GET"}   -> conn
      {"", _}      -> conn
      {nil, _}     -> conn
      {api_key, _} -> conn |> authenticate(api_key)
    end
  end

  def authenticate(conn, api_key) do
    if not Dict.has_key?(conn.params, "token"), do: raise Unauthorized

    url = "https://login2.datasektionen.se/verify/" <> conn.params["token"]
    res = get(url, query: %{api_key: api_key, format: "json"})

    if res.status_code != 200, do: raise Unauthorized

    {:ok, json} = Poison.decode(res.body)

    user = json["user"]

    group = case conn.path_info do
      ["api", "user", _, group]  -> group
      ["api", "group", group]    -> group
      ["api", "group", group, _] -> group
      _ -> raise Maru.Exceptions.MethodNotAllow
    end

    if String.ends_with? group, ".dfunkt" do
      group = String.replace_suffix group, ".dfunkt", ""
    end

    unless is_admin?(user, group), do: raise Unauthorized

    conn
  end

  def is_admin?(user, group) do
    Pls.Queries.user(user, "pls") || Pls.Queries.user(user, "pls." <> group)
  end
end
