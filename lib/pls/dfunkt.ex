defmodule Pls.Dfunkt do
  import HTTPoison

  def get_mandates(uid) do
    res = get!("https://dfunkt.datasektionen.se/api/user/kthid/" <> uid <> "/current")

    json =
      case Poison.decode(res.body) do
        {:ok, json} -> json
        {:error, _} -> %{"mandates" => []}
      end

    Enum.map(json["mandates"], & &1["Role"]["email"])
  end
end
