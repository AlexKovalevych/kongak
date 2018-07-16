defmodule Kongak.Parser do
  alias Kongak.Api
  alias Kongak.Config

  def parse_apis(%Config{data: data}) do
    data
    |> Map.get("apis", [])
    |> Enum.map(fn api ->
      struct(Api, Enum.map(api, fn {k, v} -> {String.to_atom(k), v} end))
    end)
  end

  def parse_api(data) do
  end
end
