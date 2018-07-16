defmodule Kongak.Api.Processor do
  @moduledoc """
  Kong api
  """

  alias Kongak.Api
  alias Kongak.Api.Kong
  alias Kongak.Plugin.Kong, as: KongPlugin

  def create_or_update_apis(apis) when is_list(apis) do
    current_apis = Kong.list()
    current_plugins = KongPlugin.list()
    delete_apis(current_apis, apis)
    create_apis(current_apis, apis)
    update_apis(current_apis, apis)
  end

  def create_or_update_api(%Api{} = api) do
  end

  defp create_apis(current_apis, new_apis) do
    new_apis
    |> Enum.map(fn %Api{name: name} = api ->
      unless Enum.find(current_apis, &(Map.get(&1, "name") == name)) do
        Kong.create(api)
      end
    end)
  end

  defp update_apis(current_apis, new_apis) do
    current_apis
    |> Enum.map(fn api ->
      name = api["name"]

      case Enum.find(new_apis, &(Map.get(&1, :name) == name)) do
        %Api{} = new_api ->
          if new_api.attributes == Map.take(api, Api.attributes()), do: :ok, else: Kong.update(new_api)

        nil ->
          :ok
      end
    end)
  end

  defp delete_apis(current_apis, new_apis) do
    current_apis
    |> Enum.map(fn api ->
      name = api["name"]

      unless Enum.find(new_apis, &(Map.get(&1, :name) == name)) do
        Kong.delete(name)
      end
    end)
  end
end
