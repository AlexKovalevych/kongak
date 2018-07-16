defmodule Kongak.Api.Kong do
  @moduledoc false

  use HTTPoison.Base
  alias Kongak.Api
  alias Kongak.Cache
  require Logger

  @impl true
  def process_url(url) do
    {:ok, %{host: host, port: port}} = Cache.get_config()
    "#{host}:#{port}#{url}"
  end

  @impl true
  def process_request_headers(headers), do: Keyword.put(headers, :"Content-Type", "application/json")

  @impl true
  def request(method, url, body \\ "", headers \\ [], options \\ []) do
    params = if body != "", do: ", params: #{body}", else: ""
    Logger.info("#{method}: #{url}#{params}")
    super(method, url, body, headers, options)
  end

  def list(apis \\ [], offset \\ nil) do
    url = if !offset, do: "/apis", else: "/apis?offset=#{offset}"

    with %HTTPoison.Response{body: body} <- get!(url) do
      case Jason.decode!(body) do
        %{"offset" => offset, "data" => data} -> list(apis ++ data, offset)
        %{"data" => data} -> apis ++ data
      end
    end
  end

  def get(name), do: get!("/apis/#{name}")

  def create(%Api{} = api) do
    params =
      api.attributes
      |> Map.take(Api.attributes())
      |> Map.put("name", api.name)

    post!("/apis", Jason.encode!(params))
  end

  def update(%Api{name: name} = api) do
    params = Map.take(api.attributes, Api.attributes())
    patch!("/apis/#{name}", Jason.encode!(params))
  end

  def delete(name), do: delete!("/apis/#{name}")
end
