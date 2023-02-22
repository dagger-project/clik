defmodule Clik.MixProject do
  use Mix.Project

  def project do
    [
      app: :clik,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: elixirc_options(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: [],
      test_coverage: test_coverage(),
      aliases: aliases(),
      preferred_cli_env: [cover: :test],
      escript: [main_module: Clik.Example.Main]
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
      summary: [threshold: 80],
      ignore_modules: ignore_for_test()
    ]
  end

  defp aliases() do
    [cover: "test --cover"]
  end

  defp elixirc_options(:prod), do: [warnings_as_errors: true]
  defp elixirc_options(_), do: []

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib", "example"]

  defp ignore_for_test() do
    [
      Clik.DuplicateCommandError,
      Clik.DuplicateOptionError,
      Clik.Renderable,
      Clik.UnknownCommandError,
      Clik.Test.HelloWorldCommand,
      Clik.Test.BarCommand,
      Clik.Test.BazCommand
    ]
  end
end
