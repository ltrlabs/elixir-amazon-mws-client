defmodule MWSClient.Parser do

  @moduledoc """
  Get back an enumerator based on the headers
  """

  def parse(%{body: body, headers: headers, status_code: status_code}) do
    resp = case get_content_type(headers) do
      "text/xml" <> _charset -> XmlToMap.naive_map(body)
      "text/plain;charset=" <> _charset ->
        body |> String.split("\r\n") |> CSV.decode(separator: ?\t, headers: true)
    end
    wrap_response(status_code, resp)
  end

  defp get_content_type(headers) do
    Enum.find_value headers, fn
      {"Content-Type", value} -> value
      {"content-type", value} -> value
      _ -> false
    end
  end

  # Amazon's 404 and 400 is actually an API errors not HTTP
  defp wrap_response(status_code, resp) do
    case status_code do
      200 -> {:success, resp}
      c when c in [404, 400] -> {:warn, resp}
      _-> {:error, resp}
    end
  end
end
