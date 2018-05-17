defmodule MWSClient.Utils do

  alias MWSClient.Operation
  # `URI.encode_query/1` explicitly does not percent-encode spaces, but Amazon requires `%20`
  # instead of `+` in the query, so we essentially have to rewrite `URI.encode_query/1` and
  # `URI.pair/1`.
  def percent_encode_query(query_map) do
    Enum.map_join(query_map, "&", &pair/1)
  end

  # See comment on `percent_encode_query/1`.
  defp pair({k, v}) do
    URI.encode(Kernel.to_string(k), &URI.char_unreserved?/1) <>
    "=" <> URI.encode(Kernel.to_string(v), &URI.char_unreserved?/1)
  end

  # takes a map of params, removes a key and with the values of that key,
  # should it be a list, enumerates over each element in the list
  # and puts them back into the map with key of "prefix.appendage.element_index"
  def restructure(params, prefix, appendage) do
    {list, params} = Map.pop(params, prefix)
    Map.merge(params, numbered_params("#{prefix}.#{appendage}", list))
  end

  defp numbered_params(_key, nil), do: %{}
  defp numbered_params(key, list) do
    Enum.with_index(list, 1)
    |> Enum.reduce(%{}, fn {value, index}, acc -> Map.merge(acc, %{"#{key}.#{index}" => value}) end)
  end

  def add(params, options, white_list \\ []) do
    camelized_options = options
      |> Enum.reject(fn {key, value} -> value == nil || invalid_key?(key, white_list) end)
      |> Enum.map(fn {key, value} -> { Inflex.camelize(key), value} end)
      |> Enum.into(%{})
    Map.merge(params, camelized_options)
  end

  def deep_add(params, prefix, white_list \\ []) do
    new_map =
      Map.get(params, prefix)
      |> Enum.reject(fn {key, value} -> value == nil || invalid_key?(key, white_list) end)
      |> Enum.map(fn {k, v} -> {"#{prefix}.#{Inflex.camelize(k)}", v} end)
      |> Enum.into(%{})

    params
    |> Map.delete(prefix)
    |> Map.merge(new_map)
  end

  def deep_restructure(params, prefix) do
    restructured_params =
      Map.get(params, prefix)
      |> Enum.map(fn {k, v} -> process_deep_key(prefix, k, v) end)
      |> List.flatten
      |> Enum.into(%{})

    params
    |> Map.delete(prefix)
    |> Map.merge(restructured_params)
  end

  defp process_deep_key(prefix, key, value) when is_list(value) do
    Enum.map(value, fn {k, v} -> process_deep_key([prefix, Inflex.camelize(key)], k, v)  end)
  end

  defp process_deep_key(prefix, key, value) do
    converted_prefix = process_prefix(prefix)
    {"#{converted_prefix}.#{Inflex.camelize(key)}", value}
  end

  defp process_prefix(prefix) when is_list(prefix) do
    prefix
    |> List.flatten
    |> Enum.join(".")
  end

  defp process_prefix(prefix), do: prefix

  def numbered_deep_restructure(params, prefix, appendage) do
    restructured_params =
      Map.get(params, prefix)
      |> Enum.with_index(1)
      |> Enum.map(fn {el, index} -> process_deep_map(el, [prefix, appendage, index]) end)
      |> List.flatten
      |> Enum.into(%{})

    params
    |> Map.delete(prefix)
    |> Map.merge(restructured_params)
  end

  defp process_deep_map(params, prefix), do: Enum.map(params, fn {k, v} -> process_deep_key(prefix, k, v)  end)

  defp invalid_key?(_key, []) do
    false
  end

  defp invalid_key?(key, white_list) do
    Enum.all?(white_list, &(&1 != key))
  end

  def to_operation(params, version, path, body \\ nil, headers \\ []) do
    %Operation{params: Map.merge(params, %{"Version" => version}), path: path, body: body, headers: headers}
  end

  def content_md5(data) do
    :erlang.md5(data) |> Base.encode64()
  end
end
