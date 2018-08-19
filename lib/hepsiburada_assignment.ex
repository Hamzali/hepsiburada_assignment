defmodule HepsiburadaAssignment do
  require Product
  require Campaign
  require Order
  @moduledoc """
  Documentation for HepsiburadaAssignment.
  """

  @doc """
  Entry point of hepsiburada assignment.

  ## Examples

      iex> HepsiburadaAssignment.main()
      :ok

  """
  def main do
    # TODO: Initialize ETS and datastructures.
    Product.init()
    Campaign.init()
    Order.init()
    # TODO: read the file and create the list of operations.
    # TODO: show results.
  end
end
