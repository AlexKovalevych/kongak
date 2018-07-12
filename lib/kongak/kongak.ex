defmodule Kongak do
  @moduledoc false

  def apply(args) do
    parse_args(OptionParser.parse(args, switches: [host: :string, port: :integer, path: :string]))
  end

  defp parse_args({parsed, [], []}) do
    host = Keyword.get(parsed, :host, "localhost")
    port = Keyword.get(parsed, :port, "8001")
    path = Keyword.get(parsed, :path)

    case path do
      nil -> usage(:apply)
      _ -> if File.exists?(path), do: :ok, else: error("File doesn't exist")
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
    IO.puts(msg)
    System.halt(1)
  end
end
