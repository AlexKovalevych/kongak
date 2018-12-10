defmodule Kongak.Processor.ServiceProcessor do
  @moduledoc false

  alias Kongak.Config
  alias Kongak.Kong
  alias Kongak.Server
  alias Kongak.Service
  require Logger

  def process(%Config{services: services}, %Server{} = server) do
    delete_services(server)
    create_services(services)
  end

  defp delete_services(%Server{services: server_services}) do
    Enum.map(server_services, fn server_service ->
      Kong.delete_service(server_service["name"])
    end)
  end

  defp create_services(services) do
    services
    |> Enum.map(fn %Service{} = service ->
      response = Kong.create(service)

      case response do
        %HTTPoison.Response{body: body} ->
          service_id = body |> Jason.decode!() |> Map.get("id")
          Enum.map(service.plugins || [], &Kong.create(Map.put(&1, :service_id, service_id)))

          Enum.map(service.routes, fn route ->
            response = Kong.create(%{route | service: %{id: service_id}})

            case response do
              %HTTPoison.Response{body: route_body} ->
                route_id = route_body |> Jason.decode!() |> Map.get("id")
                Enum.map(route.plugins, &Kong.create(Map.merge(&1, %{service_id: service_id, route_id: route_id})))

              error ->
                Logger.error(inspect(error))
            end
          end)

        error ->
          Logger.error(inspect(error))
      end
    end)
  end
end
