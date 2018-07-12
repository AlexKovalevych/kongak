defmodule Kongak.MixProject do
  use Mix.Project

  def project do
    [
      app: :kongak,
      version: "0.1.0",
      elixir: "~> 1.6",
      escript: escript(),
      deps: deps()
    ]
  end

  def escript do
    [main_module: Kongak.CLI]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bunt, "~> 0.2.0"}
    ]
  end
end
