defmodule UtilsTest do
  use ExUnit.Case
  doctest Utils

  test "does_product_exist returns true if product exists" do
    Product.create_product("P3", 100, 100)
    assert Utils.does_product_exist?("P3") === true
  end

  test "does_product_exist returns false if the product does not exist" do
    assert Utils.does_product_exist?("TEST_PRODUCT") === false
  end

  test "product_check returns given functions value if product exists." do
    Product.create_product("P4", 100, 100)
    assert Utils.product_check("P4", fn() -> "hello" end) === "hello"
  end

  test "product_check returns error if given product does not exist." do
    {:error, message} = Utils.product_check("SOME_VALUE", fn() -> "hello" end)
    assert message === "No such product exists."
  end
end
