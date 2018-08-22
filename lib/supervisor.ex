defmodule Hepsiburada.Supervisor do
  use Supervisor

  @moduledoc false

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      supervisor(Product.Supervisor, []),
      supervisor(Order.Supervisor, []),
      supervisor(Campaign.Supervisor, []),
      worker(TimeState, [])
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
