defmodule Kongak.Route do
  @moduledoc false

  @derive {Jason.Encoder, except: [:plugins]}

  defstruct ~w(
    protocols
    methods
    hosts
    paths
    plugins
    regex_priority
    strip_path
    preserve_host
    service
  )a
end
