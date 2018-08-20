defmodule Order do
  import Logger, only: [info: 1]
  @moduledoc """
  Order model and operations.
  """

  @doc """
  Initializes orders in ETS.
  """
  def init do
    info "Orders are initialized in ETS."
  end


  @doc """
  Creates an order record with the provided product and quantity

  ## Parameters
    - product_code: String Product identification code for placing order.
    - quantity: Integer Quatitity of the product in the order.
  """
  @spec create_order(String.t(), Integer.t()) :: :ok | {:error, String.t()}
  def create_order(product_code, quantity) do
    # TODO: check product existance.
    # TODO: check product stock.
    # TODO: create order in the ets.
    info "Order is created, product: #{product_code} quantity: #{quantity}"
  end
end
