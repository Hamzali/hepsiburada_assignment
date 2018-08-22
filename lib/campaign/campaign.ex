# Turnover is total gain in a duration of time.
defmodule Campaign do
  use GenServer

  @moduledoc """
  Order campaign and operations.

  ## Data Structure
  %{ campaign_name => { product_code, duration, price_limit, target_sales_count, total_sales, turnover, average_item_price, created_at } }
  """

  @typedoc """
  Basic campaign info.
  """
  @type campaign :: {String.t(), integer, float, integer, integer, float, float, integer}

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :campaign)
  end

  def init(_args) do
    {:ok, %{}}
  end

  @doc """
  Returns details of a campaign.

  ## Parameters
    - name: String Cmapaing name.

  ## Examples
    iex> Product.create_product("P22", 10.5, 1000)
    iex> Campaign.create_campaign("TEST_CAMPAIGN_1", "P22", 4, 30, 100)
    iex> Campaign.get_campaign_info("TEST_CAMPAIGN_1")
    {"P22", 4, 30, 100, 0, 0, 0, 10}
    iex> Campaign.get_campaign_info("SOME_VALUE")
    nil
  """
  @spec get_campaign_info(String.t()) :: Tuple.t() | {:error, String.t()}
  def get_campaign_info(name) do
    GenServer.call(:campaign, {:get_campaign_info, name})
  end

  @doc """
  Creates a campaign with given parameters.

  ## Parameters
    - name: String Cmapaing name.
    - product_code: String Product identification code for placing order.
    - duration: Integer Campaing duration in hours format.
    - price_limit: Integer Maximum discount limit for product .
    - target_sales_count: Integer Target sales count.

  ## Examples
    iex> Product.create_product("P21", 10.5, 1000)
    iex> Campaign.create_campaign("TEST_CAMPAIGN", "P21", 4, 30, 100)
    :ok
    iex> Campaign.create_campaign("TEST_CAMPAIGN", "P21", 4, 30, 100)
    {:error, "Campaign is already created."}
    iex> Campaign.create_campaign("TEST_CAMPAIGN_2", "SOME_VALUE", 4, 30, 100)
    {:error, "No such product exists."}
  """
  @spec create_campaign(String.t(), String.t(), Integer.t(), Integer.t(), Integer.t()) ::
          :ok | {:error, String.t()}
  def create_campaign(name, product_code, duration, price_limit, target_sales_count) do
    result =
      GenServer.call(
        :campaign,
        {:create_campaign, name, product_code, duration, price_limit, target_sales_count}
      )
    case result do
      :ok -> calculate_campaign_discount_amount(name, Campaign.get_campaign_info(name))
      error -> error
    end
  end

  def update_campaigns() do
    GenServer.call(:campaign, {:update_campaign})
  end

  # OTP Handlers
  def handle_call({:get_campaign_info, name}, _from, campaigns) do
    {:reply, campaigns[name], campaigns}
  end

  def handle_call(
        {:create_campaign, name, product_code, duration, price_limit, target_sales_count},
        _from,
        campaigns
      ) do
    result =
      Utils.product_check(product_code, fn ->
        cond do
          price_limit <= 0 or price_limit >= 100 ->
            {:error, "Invalid price limit, it can onlye between 0 and 100."}

          campaigns[name] !== nil ->
            {:error, "Campaign is already created."}

          true ->
            {:ok,
             Map.put(
               campaigns,
               name,
               {product_code, duration, price_limit, target_sales_count, 0, 0, 0,
                TimeState.get_current_time()}
             )}
        end
      end)

    case result do
      {:error, _} -> {:reply, result, campaigns}
      {:ok, updated_campaigns} -> {:reply, :ok, updated_campaigns}
    end
  end

  def handle_call({:update_campaign}, _from, campaigns) do
    new_campaigns =
      Enum.reduce(Map.keys(campaigns), %{}, &calculate_campaign_status(&1, &2, campaigns))

    {:reply, :ok, new_campaigns}
  end

  defp calculate_campaign_discount_amount(name, campaign) do
    {product_code, duration, price_limit, target_sales_count, total_sales_count, _,
     average_item_price, created_at} = campaign

    current_time = TimeState.get_current_time()

    {product_price, _, campaigns, _} = Product.get_product_info(product_code)

    new_discount =
      case campaigns[name] do
        nil ->
          price_limit * (10 / 100)

        prev_discount ->
          price_effect = average_item_price / product_price
          time_effect = current_time - created_at / duration
          sales_effect = total_sales_count / target_sales_count

          price_coefficient = 1
          time_coefficient = 2
          sales_coefficient = 1

          percentage =
            price_effect * price_coefficient + time_effect * time_coefficient +
              (sales_effect + sales_coefficient) /
                (price_coefficient + time_coefficient + sales_coefficient)

          prev_discount * percentage
      end

    new_discount = if new_discount > price_limit, do: price_limit, else: new_discount
    Product.add_or_update_campaign(product_code, name, new_discount)
  end

  defp calculate_campaign_status(name, new_campaigns, campaigns) do
    current_time = TimeState.get_current_time()
    campaign = campaigns[name]

    {product_code, duration, limit, target_sales_count, _total_sales, _turnover,
     _average_item_price, created_at} = campaign

    # check if campaign is still active.
    if current_time - created_at >= duration do
      Product.remove_campaign(product_code, product_code)
      Map.put(new_campaigns, name, campaign)
    else
      orders =
        Order.get_product_orders(product_code)
        |> Enum.filter(fn {_quantity, _price, order_campaigns, _created_at} ->
          Enum.member?(order_campaigns, name)
        end)

      # calculate new turnover, total sales count and average item price.
      {turnover, total_sales_count, item_price_sum} =
        Enum.reduce(orders, {0, 0, 0}, fn {quantity, sale_price, _, _}, {to, tsc, ips} ->
          {to + quantity * sale_price, tsc + quantity, ips + quantity * sale_price}
        end)

      average_item_price =
        if total_sales_count !== 0, do: item_price_sum / total_sales_count, else: 0

      # update discount value of the product.
      calculate_campaign_discount_amount(name, campaign)

      Map.put(
        new_campaigns,
        name,
        {product_code, duration, limit, target_sales_count, total_sales_count, turnover,
         average_item_price, created_at}
      )
    end
  end
end
