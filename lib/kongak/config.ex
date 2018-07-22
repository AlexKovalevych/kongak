defmodule Kongak.Config do
  @moduledoc """
  Config module
  """

  alias Kongak.Api
  alias Kongak.Plugin

  defstruct [:host, :port, :path, :data, :apis, :plugins]

  @doc """
  Yaml supported only
  """
  def parse(%__MODULE__{path: path} = config) do
    with {:ok, data} <- YamlElixir.read_from_file(path) do
      {:ok, %{config | apis: parse_apis(data), plugins: parse_plugins(data)}}
    end
  end

  def validate_path(%__MODULE__{path: path}) do
    case path do
      nil -> {:error, nil}
      _ -> if File.exists?(path), do: :ok, else: {:error, "File doesn't exist"}
    end
  end

  def parse_apis(data) do
    data
    |> Map.get("apis", [])
    |> Enum.map(fn api ->
      plugins = Enum.map(Map.get(api, "plugins", []), &parse_plugin/1)

      Api
      |> create_struct(api)
      |> Map.put(:plugins, plugins)
    end)
  end

  def parse_plugins(data) do
    data
    |> Map.get("plugins", [])
    |> Enum.map(&create_struct(Plugin, &1))
  end

  def parse_plugin(data), do: create_struct(Plugin, data)

  defp create_struct(name, data) do
    struct(name, Enum.map(data, fn {k, v} -> {String.to_atom(k), v} end))
  end
end
