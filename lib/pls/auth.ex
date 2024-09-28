defmodule Pls.Auth do
  import Plug.Conn
  import HTTPoison

  def init(options) do
    options
  end

  # Make all post and delete requests require authentication
  def call(%Plug.Conn{method: "POST"} = conn, _options) do
    authenticate(conn)
  end

  def call(%Plug.Conn{method: "DELETE"} = conn, _options) do
    authenticate(conn)
  end

  def call(conn, _) do
    conn
  end

  def authenticate(conn) do
    user = get_user(conn.params["token"])
    group = get_group(conn.path_info) |> String.split(".") |> List.first()

    # Debug
    IO.puts("#{elem(user, 1)}")
    IO.puts("#{group}")

    case check_group(user, group) do
      {:ok, user} ->
        assign(conn, :user, user)

      {:error, :missing_token} ->
        conn |> send_resp(400, "Missing token") |> halt()

      {:error, :invalid_token} ->
        conn |> send_resp(401, "Invalid token") |> halt()

      {:error, :unauthorized} ->
        conn |> send_resp(401, "Unauthorized") |> halt()
    end
  end

  defp get_group(path_info) do
    case path_info do
      ["api", "user", _, group] -> group
      ["api", "group", group] -> group
      ["api", "group", group, _] -> group
      ["api", _, _, group] -> group
      _ -> "pls"
    end
  end

  defp get_user(nil) do
    {:error, :missing_token}
  end

  defp get_user(token) do
    login_api_key = Application.get_env(:pls, :login_api_key)
    login_api_url = Application.get_env(:pls, :login_api_url)

    url = "#{login_api_url}/verify/" <> token
    res = get!(url, [], params: %{api_key: login_api_key, format: "json"})

    # Debug
    IO.puts("#{login_api_url}/verify/.../?api_key=#{login_api_key}")
    IO.puts("#{res.status_code}")
    IO.puts("#{res.body}")

    case Poison.decode(res.body) do
      {:ok, json} -> {:ok, json["user"]}
      _ -> {:error, :invalid_token}
    end
  end

  defp check_group({:error, x}, _) do
    {:error, x}
  end

  defp check_group({:ok, user}, group) do
    if Pls.Queries.User.user(user, "pls", group) or
         Pls.Queries.User.user(user, "pls", "pls") do
      {:ok, user}
    else
      IO.puts("unauthorized")
      {:error, :unauthorized}
    end
  end
end
