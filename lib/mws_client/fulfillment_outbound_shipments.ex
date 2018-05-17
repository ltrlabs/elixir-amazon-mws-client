defmodule MWSClient.FulfillmentOutboundShipments do
  alias MWSClient.Utils

  @version "2010-10-01"
  @path "/FulfillmentOutboundShipment/#{@version}"

  def create_fulfillment_order(params, opts) do
    request_params = [
      :seller_fulfillment_order_id, :fulfillment_action, :displayable_order_id, :displayable_order_comment,:items,
      :displayable_order_date_time, :shipping_speed_category, :delivery_window, :destination_address, :COD_settings,
      :notification_email_list, :fulfillment_policy
    ]
    destination_address_params = [
      :name, :line1, :line2, :country_code, :state_or_province_code, :postal_code, :city]

    %{"Action" => "CreateFulfillmentOrder"}
    |> Utils.add(params, request_params)
    |> Utils.add(opts, [:marketplace_id])
    # |> Utils.deep_add("DeliveryWindow", [:start_date_time, :end_date_time])
    |> Utils.deep_add("DestinationAddress", destination_address_params)
    # |> Utils.restructure("NotificationEmailList", "member")
    # |> Utils.deep_restructure("CODSettings")
    |> Utils.numbered_deep_restructure("Items", "member")
    |> Utils.to_operation(@version, @path)
  end
end
