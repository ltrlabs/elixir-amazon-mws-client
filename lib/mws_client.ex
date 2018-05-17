defmodule MWSClient do

  use HTTPoison.Base

  alias MWSClient.Config
  alias MWSClient.Operation
  alias MWSClient.Request
  alias MWSClient.Products
  alias MWSClient.Feed
  alias MWSClient.Subscriptions
  alias MWSClient.Orders
  alias MWSClient.Reports
  alias MWSClient.FulfillmentOutboundShipments

  @default_opts [marketplace_id: "ATVPDKIKX0DER"]

  ### FEEDS
  def submit_product_feed(xml, config = %Config{}, opts \\ [marketplace_id: "ATVPDKIKX0DER",
                                                             purge_and_replace: false]) do
    Feed.submit_product_feed(xml, opts)
    |> request(config)
  end

  def submit_variation_feed(xml, config = %Config{}, opts \\ [marketplace_id: "ATVPDKIKX0DER"]) do
    Feed.submit_variation_feed(xml, opts)
    |> request(config)
  end

  def submit_product_by_asin(xml, config = %Config{}, opts \\ [marketplace_id: "ATVPDKIKX0DER",
                                                             purge_and_replace: false]) do
    Feed.submit_product_feed(xml, opts)
    |> request(config)
  end

  def submit_price_feed(xml, config = %Config{}, opts \\ @default_opts) do
    Feed.submit_price_feed(xml, opts)
    |> request(config)
  end

  def submit_inventory_feed(xml, config = %Config{}, opts \\ @default_opts) do
    Feed.submit_inventory_feed(xml, opts)
    |> request(config)
  end

  def submit_images_feed(xml, config = %Config{}, opts \\ @default_opts) do
    Feed.submit_images_feed(xml, opts)
    |> request(config)
  end

  def get_feed_submission_result(feed_id, config = %Config{}, opts \\ @default_opts) do
    Feed.get_feed_submission_result(feed_id, opts)
    |> request(config)
  end
  ### FEEDS

  ### PRODUCTS
  def list_matching_products(query, config = %Config{}, opts \\@default_opts) do
    Products.list_matching_products(query, opts)
    |> request(config)
  end

  def get_product_by_asin(asin, config = %Config{}, opts \\ @default_opts) do
    Products.get_matching_product(asin, opts)
    |> request(config)
  end

  def get_product_categories_for_asin(asin, config = %Config{}, opts \\ @default_opts) do
    Products.get_product_categories_for_asin(asin, opts)
    |> request(config)
  end

  def get_matching_product_for_id(id, id_list, config = %Config{}, opts \\ @default_opts) do
    Products.get_matching_product_for_id(id, id_list, opts)
    |> request(config)
  end
  ### PRODUCTS

  ### SUBSCRIPTIONS
  def subscribe_to_sqs(url, config = %Config{}, opts \\ @default_opts) do
    Subscriptions.register_destination(url, opts)
    |> request(config)
  end

  def unsubscribe_from_sqs(url, config = %Config{}, opts \\ @default_opts) do
    Subscriptions.deregister_destination(url, opts)
    |> request(config)
  end
  ### SUBSCRIPTIONS

  ### ORDERS
  def list_orders(params, config = %Config{}, opts \\ [marketplace_id: ["ATVPDKIKX0DER"]]) do
    Orders.list_orders(params, opts)
    |> request(config)
  end

  def list_order_items(order_id, config = %Config{}, opts \\ @default_opts) do
    Orders.list_order_items(order_id, opts)
    |> request(config)
  end

  def get_order(order_id, config = %Config{}, opts \\ @default_opts) do
    Orders.get_order(order_id, opts)
    |> request(config)
  end
  ### ORDERS

  ### REPORTS
  def request_report(report_type, config = %Config{}, opts \\ [marketplace_id_list: ["ATVPDKIKX0DER"]]) do
    Reports.request_report(report_type, opts)
    |> request(config)
  end

  def get_report_request_list(config = %Config{}, opts) do
    Reports.get_report_request_list(opts)
    |> request(config)
  end

  def get_report_list(config = %Config{}, opts) do
    Reports.get_report_list(opts)
    |> request(config)
  end

  def get_report(report_id, config = %Config{}) do
    Reports.get_report(report_id)
    |> request(config)
  end
  ### REPORTS


  def request(operation = %Operation{}, config = %Config{}) do
    uri = Request.to_uri(operation, config)

    {status, response} = if operation.body do
      post(uri, operation.body, operation.headers)
    else
      post(uri, uri.query, operation.headers)
    end
    parse_response({status, response})
  end

  defp parse_response({status, response}) do
    case {status, response} do
      {:ok, resp} -> MWSClient.Parser.parse(resp)
      {:error, err} -> raise MWSClient.RequestError, message: inspect(err)
    end
  end

  # Fulfillment Outbound Shipments

  def create_fulfillment_order(params, config = %Config{}, opts \\ @default_opts) do
    FulfillmentOutboundShipments.create_fulfillment_order(params, opts)
    |> request(config)
  end
end
