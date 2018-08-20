
defmodule Product.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
        worker(Product, [])
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
