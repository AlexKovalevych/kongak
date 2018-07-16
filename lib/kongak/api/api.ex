defmodule Kongak.Api do
  @moduledoc false

  defstruct [:name, :plugins, :attributes]

  @attributes ~w(
    hosts
    methods
    strip_uri
    upstream_url
    uris
    preserve_host
    retries
    upstream_connect_timeout
    upstream_send_timeout
    upstream_read_timeout
    https_only
    http_if_terminated
  )

  def attributes, do: @attributes
end
