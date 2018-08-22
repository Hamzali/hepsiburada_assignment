defmodule Order do
  use GenServer

  @moduledoc """
  Order data model and operations.

  ## Data Structure
    %{ product_code => [ { quantity, price, [campaign1, campaign2], created_at } ] }
  """
  @typedoc """
  Basic order info.
  """
  @type order :: {integer, float, List.t(), integer}
  @type order_list :: [order]

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :order)
  end

  def init(_args) do
    {:ok, %{}}
  end

  @doc """
  Creates an order record with the provided product and quantity

  ## Parameters
    - product_code: String Product identification code for placing order.
    - quantity: Integer Quatitity of the product in the order.

  ##Examples
    iex> Product.create_product("P11", 100, 100)
    iex> Order.create_order("P11", 5)
    :ok
  """
  @spec create_order(String.t(), Integer.t()) :: :ok | {:error, String.t()}
  def create_order(product_code, quantity) do
    GenServer.call(:order, {:create_order, product_code, quantity})
  end

  @doc """
  Returns all orders of given product code

  ## Parameters
    - product_code: String String Product identification code.

  ## Examples
    iex> Product.create_product("P12", 100, 100)
    iex> Product.create_product("P13", 100, 100)
    iex> Order.create_order("P12", 10)
    iex> Order.get_product_orders("P12")
    [{10, 100, [], 10}]
    iex> Order.get_product_orders("P13")
    []
    iex> Order.get_product_orders("SOME_VALUE")
    {:error, "No such product exists."}
  """
  @spec get_product_orders(String.t()) :: order_list | {:error, String.t()}
  def get_product_orders(product_code) do
    GenServer.call(:order, {:get_orders, product_code})
  end

  # OTP handlers
  def handle_call({:create_order, product_code, quantity}, _from, orders) do
    result =
      Utils.product_check(product_code, fn ->
        case Product.update_stock(product_code, quantity) do
          :ok ->
            {price, _, campaigns, _} = Product.get_product_info(product_code)
            # calculate the order unit price with campaign informations.
            campaign_names = Map.keys(campaigns)
            discounted_price = Enum.reduce(campaign_names, price, fn(campaign_name, acc) -> acc - (price * (campaigns[campaign_name] / 100)) end)
            new_order = {quantity, discounted_price, campaign_names, TimeState.get_current_time()}

            if orders[product_code] === nil do
              {:ok, Map.put(orders, product_code, [new_order])}
            else
              {:ok, %{orders | product_code => [orders[product_code] | new_order]}}
            end
          error -> error
        end
      end)

    case result do
      {:error, _} -> {:reply, result, orders}
      {:ok, updated_orders} -> {:reply, :ok, updated_orders}
    end
  end

  def handle_call({:get_orders, product_code}, _from, orders) do
    {:reply,
     Utils.product_check(product_code, fn ->
       if orders[product_code] === nil do
         []
       else
         orders[product_code]
       end
     end), orders}
  end
end
