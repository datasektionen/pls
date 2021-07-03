defmodule Pls.Auth do
  import Plug.Conn
  import HTTPoison

  def init(options) do
    api_key = Keyword.get(options, :login_api_key)

    if api_key == nil do
      [:red, "Environment variable LOGIN_API_KEY is missing"] |> IO.ANSI.format |> IO.puts
      [:red, "Every request made will be allowed!"] |> IO.ANSI.format |> IO.puts
    end

    host = Keyword.get(options, :login_host)

    if host == nil do
      [:red, "Environment variable LOGIN_HOST is missing"] |> IO.ANSI.format |> IO.puts
      [:red, "Every request made will be allowed!"] |> IO.ANSI.format |> IO.puts
    end

    Map.new(options)
  end

  def call(conn, %{login_api_key: api_key, login_host: host})
    when api_key == nil or host == nil do
    conn |> assign(:user, :developer)
  end

  def call(%Plug.Conn{method: "POST"} = conn, options) do
    conn |> authenticate(options)
  end

  def call(%Plug.Conn{method: "DELETE"} = conn, options) do
    conn |> authenticate(options)
  end

  def call(conn, _) do
    conn
  end

  def authenticate(conn, options) do
    user = get_user(conn.params["token"], options)
    group = get_group(conn.path_info) |> String.split(".") |> List.first

    # Debug
    IO.puts "#{elem(user, 1)}"
    IO.puts "#{group}"

    case check_group(user, group) do
      {:ok, user} ->
        conn |> assign(:user, user)

      {:error, :missing_token} ->
        conn |> send_resp(400, "Missing token") |> halt()

      {:error, :invalid_token} ->
        conn |> send_resp(401, "Invalid token") |> halt()

      {:error, :unauthorized} ->
        conn |> send_resp(401, "Unauthorized") |> halt()
    end
  end

  def get_group(path_info) do
    case path_info do
      ["api", "user", _, group]    -> group
      ["api", "group", group]      -> group
      ["api", "group", group, _]   -> group
      ["api", _, _, group]         -> group
      _ -> "pls"
    end
  end

  def get_user(nil, _) do
    {:error, :missing_token}
  end

  def get_user(token, %{login_host: login_host, login_api_key: api_key}) do
    url = "https://#{login_host}/verify/" <> token
    res = get!(url, [], params: %{api_key: api_key, format: "json"})
    
    # Debug
    IO.puts "https://#{login_host}/verify/.../?api_key=#{api_key}"
    IO.puts "#{res.status_code}"
    IO.puts "#{res.body}"

    case Poison.decode(res.body) do
      {:ok, json} -> {:ok, json["user"]}
      _           -> {:error, :invalid_token}
    end
  end

  def check_group({:error, x}, _) do
    {:error, x}
  end

  def check_group({:ok, user}, group) do
    if Pls.Queries.User.user(user, "pls", group) or
      Pls.Queries.User.user(user, "pls", "pls") do
        {:ok, user}
      else
        IO.puts "unauthorized"
        {:error, :unauthorized}
      end
  end


end
