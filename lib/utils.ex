defmodule Utils do
  @moduledoc """
  Some reusable helper methods.
  """

  @doc """
  Checks for product existance.

  ## Parameters
    - product_code: String Unique product identification code.
  """
  @spec does_product_exist?(String.t()) :: true | false
  def does_product_exist?(code) do
    if Product.get_product_info(code) == nil do
      false
    else
      true
    end
  end

  @doc """
  Checks product existance and applies given method.

  ## Parameters
    - product_code: String Unique product identification code.
    - method: Function Logic to apply.
  """
  @spec product_check(String.t(), Function.t()) :: {:error, String.t()}
  def product_check(product_code, method) do
    if Utils.does_product_exist?(product_code) do
      method.()
    else
      {:error, "No such product exists."}
    end
  end
end
