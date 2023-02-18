defmodule Clik.MixProject do
  use Mix.Project

  def project do
    [
      app: :clik,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: [],
      test_coverage: test_coverage(),
      aliases: aliases(),
      preferred_cli_env: [cover: :test]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp test_coverage() do
    [
      summary: [threshold: 80]
    ]
  end

  defp aliases() do
    [cover: "test --cover"]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
