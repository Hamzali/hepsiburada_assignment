defmodule OrderTest do
  use ExUnit.Case
  doctest Order

  test "create_order fails if product does not exist." do
    {:error, message} = Order.create_order("SOME_VALUE", 100)
    assert message === "No such product exists."
  end
end
