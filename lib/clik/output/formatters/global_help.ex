defmodule Clik.Output.Formatters.GlobalHelp do
  alias Clik.{Configuration, Platform}
  alias Clik.Output.{Document, Table}
  alias Clik.Output.Formatters.Options
  @global_option_section_name "Global options"

  @spec format(Configuration.t(), Document.t()) :: Document.t()
  def format(config, doc) do
    doc =
      if config.script_help != nil do
        doc
        |> Document.line(config.script_help)
        |> Document.line("")
      else
        doc
      end

    doc = Document.text(doc, "USAGE: #{Platform.script_name()}")

    command_count = Enum.count(config.commands) - 1

    doc =
      if command_count > 0 do
        Document.text(doc, " <cmd> ")
      else
        doc
      end

    options =
      Enum.map(config.global_options, fn {_key, option} -> Options.format_name(option) end)
      |> Enum.join("")

    doc = Document.line(doc, options)

    doc =
      if command_count > 0 do
        Document.line(doc, "Commands: #{available_commands(config)}")
        |> Document.line("")
      else
        doc
      end

    flags =
      Enum.reduce(config.global_options, Table.empty(), fn {_, option}, flags ->
        Table.add_row(flags, [Options.format_name(option, true), Options.format_help(option)])
      end)

    Document.line(doc, "")
    |> Document.section_head(@global_option_section_name)
    |> Document.table(flags)
  end

  defp available_commands(config) do
    Enum.map(Map.keys(config.commands), &Atom.to_string(&1))
    |> Enum.join(",")
  end
end
