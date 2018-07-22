defmodule Kongak.Processor.CertificateProcessor do
  @moduledoc false

  alias Kongak.Certificate
  alias Kongak.Config
  alias Kongak.Kong
  alias Kongak.Server

  def process(%Config{certificates: certificates}, %Server{} = server) do
    delete(server)
    create(certificates)
  end

  defp delete(%Server{certificates: certificates}) do
    Enum.map(certificates, &Kong.delete_certificate(Map.get(&1, "id")))
  end

  defp create(certificates) do
    Enum.map(certificates, &Kong.create/1)
  end

  # defp compare(certificate, server_certificate) do
  #   attributes = ~w(cert key snis)

  #   new_certificate =
  #     certificate
  #     |> Jason.encode!()
  #     |> Jason.decode!()
  #     |> Map.take(attributes)
  #     |> Enum.filter(fn {_, v} -> !is_nil(v) end)

  #   server_certificate =
  #     server_certificate
  #     |> Map.take(attributes)
  #     |> Enum.filter(fn {_, v} -> !is_nil(v) end)

  #   new_certificate == server_certificate
  # end
end
