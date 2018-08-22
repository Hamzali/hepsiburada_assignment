defmodule HepsiburadaAssignment do
  use Application
  require Logger

  @moduledoc """
  Documentation for HepsiburadaAssignment.
  """

  def start(_type, _args) do
    Hepsiburada.Supervisor.start_link(name: Hepsiburada.Supervisor)
  end

  defp handle_commands(["create_product", code, price, stock]) do
    {float_price, _} = Float.parse(price)

    case Product.create_product(code, float_price, String.to_integer(stock)) do
      :ok -> "Product created; code #{code}, price #{float_price}, stock #{stock}"
      {:error, message} -> "create_product failed: #{message}"
    end
  end

  defp handle_commands(["get_product_info", code]) do
    case Product.get_product_info(code) do
      {price, stock, _, _} -> "Product; code #{code}, price #{price}, stock #{stock}"
      nil -> "get_product_info failed: Product does not exist."
    end
  end

  defp handle_commands([
         "create_campaign",
         name,
         product_code,
         duration,
         price_limit,
         target_sales_count
       ]) do
    case Campaign.create_campaign(
           name,
           product_code,
           String.to_integer(duration),
           String.to_integer(price_limit),
           String.to_integer(target_sales_count)
         ) do
      :ok ->
        "Campaign created; name #{name}, product #{product_code}, duration #{duration}, limit #{
          price_limit
        }, target sales count #{target_sales_count}"

      {:error, message} ->
        "create_campaign failed: #{message}"
    end
  end

  defp handle_commands(["get_campaign_info", name]) do
    case Campaign.get_campaign_info(name) do
      {product_code, duration, limit, target_sales_count, total_sales, turnover,
       average_item_price, created_at} ->
        "Campaign #{name} Product #{product_code} info; Limit #{limit} Status #{
          if TimeState.get_current_time() - created_at > duration, do: "Inactive", else: "Active"
        }, Target Sales #{target_sales_count}, Total Sales #{total_sales}, Turnover #{turnover}, Average Item Price #{
          average_item_price
        }"

      nil ->
        "Campaign does not exists."
    end
  end

  defp handle_commands(["increase_time", amount]) do
    String.to_integer(amount) |> TimeState.increase_time()
    Campaign.update_campaigns()
    "Time is #{TimeState.get_current_time()}"
  end

  defp handle_commands(["create_order", product_code, quantity]) do
    case Order.create_order(product_code, String.to_integer(quantity)) do
      :ok -> "Order created; product #{product_code}, quantity #{quantity}"
      {:error, message} -> "create_order failed: #{message}"
    end
  end

  defp handle_commands(_cl) do
    "invalid command"
  end

  defp write_output(data) do
    case File.write("output.txt", data) do
      :ok -> "Succesfully writed out"
      {:error, _} -> "Something went wrong."
    end
  end

  def main(args) do
    [filepath] = args

    case File.read(filepath) do
      {:error, :enoent} ->
        Logger.error("File does deos not exist.")

      {:error, :eacces} ->
        Logger.error("Permissions are missing for this operation.")

      {:error, :enospc} ->
        Logger.error("There is not enough space in the device.")

      {:error, :eisdir} ->
        Logger.error("File path you provided is a directory.")

      {:ok, data} ->
        String.split(data, "\n")
        |> Enum.map(&(String.split(&1, " ") |> handle_commands))
        # |> Enum.map(&handle_commands(&1))
        |> Enum.join("\n")
        |> write_output
    end

    # TODO: show results or write to a file.
    :ok
  end
end
