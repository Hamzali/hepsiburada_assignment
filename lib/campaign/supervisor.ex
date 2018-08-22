defmodule Campaign.Supervisor do
  use Supervisor

  @moduledoc false

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Campaign, [])
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
