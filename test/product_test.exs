defmodule ProductTest do
  use ExUnit.Case
  doctest Product

  test "create_product if product code is already used returns error" do
    Product.create_product("P1", 100, 100)
    {:error, message} = Product.create_product("P1", 110, 110)

    assert message == "Product is already created."
  end
end
