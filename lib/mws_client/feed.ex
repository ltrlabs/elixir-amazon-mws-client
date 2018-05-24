defmodule MWSClient.Feed do
  @version "2009-01-01"
  @path "/Feeds/#{@version}"
  @opts [marketplace_id: "ATVPDKIKX0DER"]

  alias MWSClient.Utils

  def submit_product_feed(data, opts \\ @opts) do
    %{"Action" => "SubmitFeed",
      "FeedType" => "_POST_PRODUCT_DATA_"}
      |> Utils.add(opts, [:marketplace_id, :purge_and_replace])
      |> Utils.to_operation(@version, @path, data, ["Content-MD5": Utils.content_md5(data)])
  end

  def submit_variation_feed(data, opts \\ @opts) do
    %{"Action" => "SubmitFeed",
      "FeedType" => "_POST_PRODUCT_RELATIONSHIP_DATA_"}
      |> Utils.add(opts, [:marketplace_id])
      |> Utils.to_operation(@version, @path, data, ["Content-MD5": Utils.content_md5(data)])
  end

  def submit_price_feed(data, opts \\ @opts) do
    %{"Action" => "SubmitFeed",
      "FeedType" => "_POST_PRODUCT_PRICING_DATA_"}
      |> Utils.add(opts, [:marketplace_id])
      |> Utils.to_operation(@version, @path, data, ["Content-MD5": Utils.content_md5(data)])
  end

  def submit_inventory_feed(data, opts \\ @opts) do
    %{"Action" => "SubmitFeed",
      "FeedType" => "_POST_INVENTORY_AVAILABILITY_DATA_"}
      |> Utils.add(opts, [:marketplace_id])
      |> Utils.to_operation(@version, @path, data, ["Content-MD5": Utils.content_md5(data)])
  end

  def submit_images_feed(data, opts \\ @opts) do
    %{"Action" => "SubmitFeed",
      "FeedType" => "_POST_PRODUCT_IMAGE_DATA_"}
      |> Utils.add(opts, [:marketplace_id])
      |> Utils.to_operation(@version, @path, data, ["Content-MD5": Utils.content_md5(data)])
  end

  def get_feed_submission_result(feed_id, opts \\ @opts) do
    %{"Action" => "GetFeedSubmissionResult",
      "FeedSubmissionId" => feed_id}
      |> Utils.add(opts, [:marketplace_id])
      |> Utils.to_operation(@version, @path, nil, [])
  end

  def submit_fulfillment_order_request_feed(data, opts \\ @opts) do
    %{"Action" => "SubmitFeed",
      "FeedType" => "_POST_FULFILLMENT_ORDER_REQUEST_DATA_"}
      |> Utils.add(opts, [:marketplace_id])
      |> Utils.to_operation(@version, @path, data, ["Content-MD5": Utils.content_md5(data)])
  end
end
