defmodule Kongak do
  @moduledoc false

  alias Kongak.Application
  alias Kongak.Cache
  alias Kongak.Config
  alias Kongak.Api.Processor, as: Apis
  alias Kongak.Parser

  def apply(args) do
    Application.start(nil, nil)
    {:ok, config} = parse_args(OptionParser.parse(args, switches: [host: :string, port: :integer, path: :string]))

    with {:ok, config} <- Config.parse(config) do
      Cache.set_config(config)

      config
      |> Parser.parse_apis()
      |> Apis.create_or_update_apis()
    else
      {:error, reason} -> error(reason)
    end
  end

  defp parse_args({parsed, [], []}) do
    config = %Config{
      host: Keyword.get(parsed, :host, "localhost"),
      port: Keyword.get(parsed, :port, "8001"),
      path: Keyword.get(parsed, :path)
    }

    case Config.validate_path(config) do
      :ok -> {:ok, config}
      {:error, nil} -> usage(:apply)
      {:error, msg} -> error(msg)
    end
  end

  def dump(args) do
  end

  defp usage(:apply) do
    IO.puts("""
    Applies configuration to kong server

    Usage: kongak apply --path <filepath>

    Options:

      --host (optional) Connection host, default to "localhost"
      --port (optional) Connection port, default to "8000"
      --path (required) path to konfiguration file

    """)

    System.halt()
  end

  defp usage(:dump) do
    IO.puts("""
    Dump configuration from kong to file

    Usage: kongak dump --path <filepath>

    Options:

      --host (optional) Connection host, default to "localhost"
      --port (optional) Connection port, default to "8000"
      --path (required) path to configuration file to be created

    """)

    System.halt()
  end

  defp error(msg) do
    [:red, :bright, msg]
    |> IO.ANSI.format(true)
    |> IO.puts()

    System.halt(1)
  end
end
