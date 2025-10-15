defmodule Ash2385.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [Ash2385.Repo]

    opts = [strategy: :one_for_one, name: Ash2385.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
