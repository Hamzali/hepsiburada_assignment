defmodule Campaign do
  use GenServer
  import Logger, only: [info: 1]

  @moduledoc """
  Order campaign and operations.
  """

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :campaign)
  end

  @doc """
  Initializes campaings genserver.
  """
  def init(_args) do
    info("Campaings are initialized.")
    {:ok, %{}}
  end

  @doc """
  Creates a campaign woth given parameters.

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
    GenServer.call(
      :campaign,
      {:create_campaign, name, product_code, duration, price_limit, target_sales_count}
    )
  end

  # OTP Handlers
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
            info(
              "Campaign is created, name: #{name} product: #{product_code} duration: #{duration} limit: #{
                price_limit
              } targer_sales_count: #{target_sales_count}"
            )

            {:ok,
             Map.put(
               campaigns,
               name,
               {product_code, duration, price_limit, target_sales_count}
             )}
        end
      end)

    case result do
      {:error, _} -> {:reply, result, campaigns}
      {:ok, updated_campaigns} -> {:reply, :ok, updated_campaigns}
    end
  end
end
