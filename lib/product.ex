defmodule Product do
  import Logger, only: [info: 1]

  @moduledoc """
  Product data model and operations.
  """

  @doc """
  Initializes products in ETS.
  """
  def init do
    info "initialized products"
  end

  @doc """
  Creates product with given code, price and stock information.

  ## Parameters

    - code: String Unique product identification code.
    - price: Float Unit price of the product.
    - stock: Integer Total number of products in the inventory
  """
  @spec create_product(String.t(), Float.t(), Integer.t()) :: :ok | {:error, String.t()}
  def create_product(code, price, stock) do
    # TODO: check the product code if it is duplicate then return error.
    # TODO: populate the product in the ets.
    info "Product with code: #{code} price: #{price} stock: #{stock} is created."
  end
end
