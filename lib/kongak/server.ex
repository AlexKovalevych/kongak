defmodule Kongak.Server do
  @moduledoc """
  Defines current server state
  """
  defstruct apis: [],
            api_plugins: [],
            service_plugins: [],
            route_plugins: [],
            global_plugins: [],
            certificates: [],
            upstreams: [],
            consumers: [],
            services: [],
            routes: []
end
