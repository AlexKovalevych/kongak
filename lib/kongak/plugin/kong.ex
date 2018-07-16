defmodule Kongak.Plugin.Kong do
  @moduledoc false

  use HTTPoison.Base
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

  def list(plugins \\ [], offset \\ nil) do
    url = if !offset, do: "/plugins", else: "/plugins?offset=#{offset}"

    with %HTTPoison.Response{body: body} <- get!(url) do
      case Jason.decode!(body) do
        %{"offset" => offset, "data" => data} -> list(plugins ++ data, offset)
        %{"data" => data} -> plugins ++ data
      end
    end
  end
end
