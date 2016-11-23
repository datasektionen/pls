defmodule Pls.Auth do
  import HTTPotion

  defmodule Unauthorized do
    defexception message: "Authentication failed"
  end

  def init(options) do
    if api_key in ["", nil] do
      [:red, "Environment variable LOGIN_API_KEY is missing"] |> IO.ANSI.format |> IO.puts
      [:red, "Every request made will be allowed"] |> IO.ANSI.format |> IO.puts
    end

    options
  end
  
  def call(conn, _opts) do
    case {is_enabled?, conn.method} do
      {_, "GET"} -> conn
      {false, _} -> conn
      {true,  _} -> conn |> authenticate
    end
  end

  def is_enabled? do
    not api_key in ["", nil]
  end

  def api_key do
    Application.get_env(:pls, :api_key)
  end

  def authenticate(conn) do
    if not Dict.has_key?(conn.params, "token"), do: raise Unauthorized

    user = get_user(conn.params["token"])

    unless user, do: raise Unauthorized

    group = case conn.path_info do
      ["api", "user", _, group]    -> group
      ["api", "group", group]      -> group
      ["api", "group", group, _]   -> group
      ["api", "mandate", _, group] -> group
      _ -> raise Maru.Exceptions.MethodNotAllow
    end

    group = String.split(group, ".") |> List.first

    unless is_admin?(user, group), do: raise Unauthorized

    conn
  end

  def get_user(token) do
    url = "https://login2.datasektionen.se/verify/" <> token
    res = get(url, query: %{api_key: api_key, format: "json"})

    case Poison.decode(res.body) do
      {:ok, json} -> json["user"]
      _           -> false
    end
  end

  def is_admin?(user, group) do
    Pls.Queries.user(user) |> Map.has_key?("pls") ||
    Pls.Queries.user(user) |> Map.has_key?("pls." <> group)
  end
end
