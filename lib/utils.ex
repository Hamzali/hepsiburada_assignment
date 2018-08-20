defmodule Utils do

  @spec does_product_exist?(String.t()) :: true | false
  def does_product_exist?(code) do
    if Product.get_product_info(code) == nil  do
      false
    else
      true
    end
  end

  def product_check(product_code, method) do
    if Utils.does_product_exist?(product_code) do
      method.()
    else
      {:error, "No such product exists."}
    end
  end
end
