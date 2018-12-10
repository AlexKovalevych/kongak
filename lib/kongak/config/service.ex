defmodule Kongak.Service do
  @moduledoc false

  @derive {Jason.Encoder, except: [:routes, :plugins]}

  defstruct ~w(
    name
    protocol
    host
    port
    path
    routes
    plugins
    connect_timeout
    read_timeout
    write_timeout
    retries
  )a
end
