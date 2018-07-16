defmodule Kongak.Config do
  @moduledoc """
  Config module
  """

  defstruct [:host, :port, :path, :data]

  @doc """
  Yaml supported only
  """
  def parse(%__MODULE__{path: path} = config) do
    with {:ok, data} <- YamlElixir.read_from_file(path) do
      {:ok, %{config | data: data}}
    end
  end

  def validate_path(%__MODULE__{path: path}) do
    case path do
      nil -> {:error, nil}
      _ -> if File.exists?(path), do: :ok, else: {:error, "File doesn't exist"}
    end
  end
end
