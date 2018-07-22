defmodule Kongak.Kong do
  @moduledoc false

  use HTTPoison.Base
  alias Kongak.Api
  alias Kongak.Cache
  alias Kongak.Plugin
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

  def list(type, items \\ [], offset \\ nil)

  def list(:api, apis, offset) do
    url = if !offset, do: "/apis", else: "/apis?offset=#{offset}"

    with %HTTPoison.Response{body: body} <- get!(url) do
      case Jason.decode!(body) do
        %{"offset" => offset, "data" => data} -> list(:api, apis ++ data, offset)
        %{"data" => data} -> apis ++ data
      end
    end
  end

  def list(:plugin, plugins, offset) do
    url = if !offset, do: "/plugins", else: "/plugins?offset=#{offset}"

    with %HTTPoison.Response{body: body} <- get!(url) do
      case Jason.decode!(body) do
        %{"offset" => offset, "data" => data} -> list(:plugin, plugins ++ data, offset)
        %{"data" => data} -> plugins ++ data
      end
    end
  end

  def create(%Api{} = api) do
    post!("/apis", Jason.encode!(api))
  end

  def create(%Plugin{} = plugin) do
    post!("/plugins", Jason.encode!(plugin))
  end

  def create(%Api{name: name}, %Plugin{} = plugin) do
    post!("/apis/#{name}/plugins", Jason.encode!(plugin))
  end

  def update(%Api{name: name} = api) do
    patch!("/apis/#{name}", Jason.encode!(api))
  end

  def update(%Api{name: name}, %Plugin{} = plugin, plugin_id) do
    patch!("/apis/#{name}/plugins/#{plugin_id}", Jason.encode!(plugin))
  end

  def delete_api(name), do: delete!("/apis/#{name}")

  def delete_plugin(id), do: delete!("/plugins/#{id}")
end
