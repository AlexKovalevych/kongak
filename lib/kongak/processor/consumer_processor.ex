defmodule Kongak.Processor.ConsumerProcessor do
  @moduledoc false

  alias Kongak.Config
  alias Kongak.Consumer
  alias Kongak.Kong
  alias Kongak.Server

  def process(%Config{consumers: consumers}, %Server{} = server) do
    delete(server)
    create(consumers)
  end

  @doc """
  Delete all consumers since we can't identify their credentials
  """
  def delete(%Server{consumers: server_consumers}) do
    server_consumers
    |> Enum.map(fn server_consumer ->
      username_or_custom_id = server_consumer["username"] || server_consumer["custom_id"]
      Kong.delete_consumer(username_or_custom_id)
    end)
  end

  @doc """
  Create all consumers with their credentials
  """
  def create(consumers) do
    consumers
    |> Enum.map(fn
      %Consumer{username: nil, custom_id: nil} ->
        nil

      %Consumer{} = consumer ->
        Kong.create(consumer)
    end)
  end
end
