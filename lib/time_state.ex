defmodule TimeState do
  use GenServer

  @moduledoc """
  Contains time state and manipulation methods.
  """

  def start_link do
    GenServer.start_link(__MODULE__, 0, name: :time_state)
  end

  def init(_args) do
    {:ok, 0}
  end

  @doc """
  Increases time by given time.

  ## Parameters
    - amount: Integer amount of increase in time

  ## Examples
    iex> TimeState.increase_time(10)
    :ok
    iex> TimeState.get_current_time()
    10
  """
  @spec increase_time(Integer.t()) :: :ok | {:error, String.t()}
  def increase_time(amount) do
    GenServer.call(:time_state, {:increase_time, amount})
  end

  @doc """
  Returns current time state.
  """
  def get_current_time do
    GenServer.call(:time_state, {:get_current_time})
  end

  # OTP handlers
  def handle_call({:increase_time, amount}, _from, current_time) do
    if amount <= 0 do
      {:reply, {:error, "Amount cannot be negative or zero."}, current_time}
    else
      {:reply, :ok, current_time + amount}
    end
  end

  def handle_call({:get_current_time}, _from, current_time) do
    {:reply, current_time, current_time}
  end
end
