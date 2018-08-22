defmodule Product do
  use GenServer

  @moduledoc """
  Product data model and operations.

  ## Data Structure
  %{ code => { price, stock, %{ campaign_name => discount_amount },  created_at } }
  """

  @typedoc """
  Basic product info.
  """
  @type product :: { float, integer, Map.t(), integer }

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :product)
  end

  def init(_args) do
    {:ok, %{}}
  end

  @doc """
  Returns a product price and stock with the given code.

  ## Parameters
    - code: String Unique product identification code.

  ## Examples
    iex> Product.create_product("P03", 100, 200)
    iex> Product.get_product_info("P03")
    {100, 200, %{}, 10}

    iex> Product.get_product_info("SOME_VALUE")
    nil
  """
  @spec get_product_info(String.t()) :: product | nil
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
    :ok

  """
  @spec create_product(String.t(), Float.t(), Integer.t()) :: :ok | {:error, String.t()}
  def create_product(code, price, stock) do
    GenServer.call(:product, {:create_product, code, price, stock})
  end

  @doc """
  Updates campaign info of a product. Adds campaign if the campaign is already added else creates new one.

  ## Parameters

    - code: String Unique product identification code.
    - campaign: String Unique campaign name.
    - discount: Float Calculated discount amount of the campaign.
  """
  @spec add_or_update_campaign(String.t(), String.t(), Float.t()) :: :ok | {:error, String.t()}
  def add_or_update_campaign(code, campaign, discount) do
    GenServer.call(:product, {:add_or_update_campaign, code, campaign, discount})
  end

  @doc """
  Removes a campaign from a product.

  ## Parameters

    - code: String Unique product identification code.
    - campaign: String Unique campaign name.
  """
  @spec remove_campaign(String.t(), String.t()) :: :ok | {:error, String.t()}
  def remove_campaign(code, campaign) do
    GenServer.call(:product, {:remove_campaign, code, campaign})
  end

  @spec update_stock(String.t(), Integer.t()) :: :ok | {:error, String.t()}
  def update_stock(code, amount) do
    GenServer.call(:product, {:update_stock, code, amount})
  end

  # OTP handlers
  def handle_call({:get_product_info, code}, _from, products) do
    product = Map.get(products, code)
    {:reply, product, products}
  end

  def handle_call({:create_product, code, price, stock}, _from, products) do
    product = Map.get(products, code)

    if product === nil do
      {:reply, :ok, Map.put(products, code, {price, stock, %{}, TimeState.get_current_time()})}
    else
      {:reply, {:error, "Product is already created."}, products}
    end
  end

  def handle_call({:add_or_update_campaign, code, campaign, discount}, _from, products) do
    product = Map.get(products, code)

    if product === nil do
      {:reply, {:error, "Cannot add campaign to a non existant product."}, products}
    else
      {price, stock, campaigns, created_at} = product

      if campaigns[campaign] === nil do
        {:reply, :ok,
         %{products | code => {price, stock, Map.put(campaigns, campaign, discount), created_at}}}
      else
        {:reply, :ok,
         %{products | code => {price, stock, %{campaigns | campaign => discount}, created_at}}}
      end
    end
  end

  def handle_call({:remove_campaign, code, campaign}, _from, products) do
    product = Map.get(products, code)

    if product === nil do
      {:reply, {:error, "Cannot remove campaign from a non existant product."}, products}
    else
      {price, stock, campaigns, created_at} = product

      if campaigns[campaign] === nil do
        {:reply, {:error, "Campaign is already removed from product."}, products}
      else
        {:reply, :ok,
         %{products | code => {price, stock, Map.delete(campaigns, campaign), created_at}}}
      end
    end
  end

  def handle_call({:update_stock, code, amount}, _from, products) do
    product = Map.get(products, code)

    if product === nil do
      {:reply, {:error, "Cannot update stock of a non existant product."}, products}
    else
      {price, stock, campaigns, created_at} = product

      if amount > stock do
        {:reply, {:error, "Product stock is insufficient."}, products}
      else
        {:reply, :ok,
         %{products | code => {price, stock - amount, campaigns, created_at}}}
      end
    end
  end
end
