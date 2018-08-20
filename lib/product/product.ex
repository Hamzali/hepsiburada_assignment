defmodule Product do
  use GenServer
  import Logger, only: [info: 1]

  @moduledoc """
  Product data model and operations.
  """

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :product)
  end

  @doc """
  Initializes products gen server.
  """
  def init(_args) do
    info("initialized products")
    {:ok, %{}}
  end

  @doc """
  Returns the product with given code
  """
  @spec get_product_info(String.t()) :: {:reply, Tupele.t()}
  def get_product_info(code) do
    GenServer.call(:product, {:get_product_info, code})
  end

  @doc """
  Creates product with given code, price and stock information.

  ## Parameters

    - code: String Unique product identification code.
    - price: Float Unit price of the product.
    - stock: Integer Total number of products in the inventory

  ## Examples

    iex> Product.create_product("P1", 100, 100)
    {:ok, "P1"}

  """
  @spec create_product(String.t(), Float.t(), Integer.t()) :: :ok | {:error, String.t()}
  def create_product(code, price, stock) do
    GenServer.call(:product, {:create_product, code, price, stock})
  end

  # OTP handlers
  def handle_call({:get_product_info, code}, _from, products) do
    product = Map.get(products, code)
    {:reply, product, products}
  end

  def handle_call({:create_product, code, price, stock}, _from, products) do
    product = Map.get(products, code)
    if product === nil do
      info("Product with code: #{code} price: #{price} stock: #{stock} is created.")
      {:reply, {:ok, code}, Map.put(products, code, {price, stock})}
    else
      {:reply, {:error, "Product is already created."}, products}
    end
  end
end
