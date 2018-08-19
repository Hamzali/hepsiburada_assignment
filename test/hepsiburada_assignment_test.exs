defmodule HepsiburadaAssignmentTest do
  use ExUnit.Case
  doctest HepsiburadaAssignment

  test "initializes the data." do
    assert HepsiburadaAssignment.main() == :ok
  end
end
