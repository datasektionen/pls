require IEx
defmodule Mix.Tasks.Pls do
  use Mix.Task
  import Mix.Ecto


  def run(_) do
    ensure_started(Pls.Repo, [])
    Application.ensure_started(:pls)
    IEx.pry
  end
end
