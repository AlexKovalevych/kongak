defmodule Kongak.Processor do
  @moduledoc """
  Kong api
  """

  alias Kongak.Api
  alias Kongak.Config
  alias Kongak.Kong

  def process_apis(%Config{apis: apis}) do
    current_apis = Kong.list(:api)
    current_plugins = Kong.list(:plugin)
    delete_apis(current_apis, apis)
    create_apis(current_apis, current_plugins, apis)
    update_apis(current_apis, current_plugins, apis)
  end

  defp create_apis(current_apis, current_plugins, new_apis) do
    new_apis
    |> Enum.map(fn %Api{name: name} = api ->
      unless Enum.find(current_apis, &(Map.get(&1, "name") == name)) do
        Kong.create(api)
      end
    end)
  end

  defp update_apis(current_apis, current_plugins, new_apis) do
    current_apis
    |> Enum.map(fn current_api ->
      name = current_api["name"]

      case Enum.find(new_apis, &(Map.get(&1, :name) == name)) do
        %Api{} = new_api ->
          if compare_apis(new_api, current_api), do: :ok, else: Kong.update(new_api)

        nil ->
          :ok
      end
    end)
  end

  defp compare_apis(new_api, current_api) do
    attributes = ~w(
      hosts
      http_if_terminated
      https_only
      name
      preserve_host
      retries
      strip_uri
      methods
      uris
      upstream_connect_timeout
      upstream_read_timeout
      upstream_send_timeout
      upstream_url
    )

    new_api =
      new_api
      |> Jason.encode!()
      |> Jason.decode!()
      |> Map.take(attributes)
      |> Enum.filter(fn {k, v} -> !is_nil(v) end)

    current_api =
      current_api
      |> Map.take(attributes)
      |> Enum.filter(fn {k, v} -> !is_nil(v) end)

    new_api == current_api
  end

  defp delete_apis(current_apis, new_apis) do
    current_apis
    |> Enum.map(fn api ->
      name = api["name"]

      unless Enum.find(new_apis, &(Map.get(&1, :name) == name)) do
        Kong.delete(:api, name)
      end
    end)
  end
end
