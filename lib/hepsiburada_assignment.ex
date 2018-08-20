defmodule HepsiburadaAssignment do
  use Application
  @moduledoc """
  Documentation for HepsiburadaAssignment.
  """

  def start(_type, _args) do
    Hepsiburada.Supervisor.start_link(name: Hepsiburada.Supervisor)
  end

  @doc """
  Entry point of hepsiburada assignment.

  ## Examples

      iex> HepsiburadaAssignment.main()
      :ok

  """
  def main do
    # TODO: Initialize datastructures.
    # TODO: read the file and create the list of operations.
    # TODO: show results.
    :ok
  end
end
