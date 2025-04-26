defmodule Pls.StripJWTPrefix do
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{path_info: ["api", "jwt" | rest]} = conn, _opts) do
    conn
    |> Map.put(:path_info, ["api" | rest])
    |> Map.update!(:request_path, fn path ->
      String.replace_prefix(path, "/api/jwt", "/api")
    end)
    |> put_private(:resp_type, :jwt)
  end

  def call(%Plug.Conn{path_info: ["api" | _]} = conn, _opts) do
    put_private(conn, :resp_type, :json)
  end

  def call(conn, _opts), do: conn
end
