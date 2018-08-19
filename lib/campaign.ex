defmodule Campaign do
  import Logger, only: [info: 1]

  @moduledoc """
  Order campaign and operations.
  """

  @doc """
  Initializes campaings in ETS.
  """
  def init do
    info "Campaings are initialized in ETS."
  end

  @doc """
  Creates a campaign.

  ## Parameters
    - name: String Cmapaing name.
    - product_code: String Product identification code for placing order.
    - duration: Integer Campaing duration in hours format.
    - price_limit: Integer Maximum discount limit for product .
    - target_sales_count: Integer Target sales count.
  """
  @spec create_campaign(String.t(), String.t(), Integer.t(), Integer.t(), Integer.t()) :: :ok | {:error, String.t()}
  def create_campaign(name, product_code, duration, price_limit, target_sales_count) do
    # TODO: check campaign name uniqueness.
    # TODO: check product existance.
    # TODO: validate price limit.
    info "Campaign is created, name: #{name} product: #{product_code} duration: #{duration} limit: #{price_limit} targer_sales_count: #{target_sales_count}"
  end
end
