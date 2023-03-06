defmodule Clik.Output.Formatters.SingleCommandHelp do
  alias Clik.{Command, Configuration, Platform}
  alias Clik.Output.{Document, Table}
  alias Clik.Output.Formatters.Options

  @global_option_section_name "Options"

  @spec format(Configuration.t(), Document.t()) :: Document.t()
  def format(config, doc) do
    [command] = Map.values(config.commands)

    doc =
      if config.script_help != nil do
        doc
        |> Document.line(config.script_help)
      else
        doc
      end

    doc =
      if Command.help_text(command) != nil do
        doc
        |> Document.line(Command.help_text(command))
      else
        doc
      end

    doc = Document.text(doc, "USAGE: #{Platform.script_name()}")

    options =
      Enum.map(config.global_options, fn {_key, option} -> Options.format_name(option) end)

    options =
      Enum.reduce(Command.options(command), options, fn option, acc ->
        [Options.format_name(option) | acc]
      end)
      |> Enum.join("")

    doc = Document.line(doc, options)

    flags =
      Enum.reduce(config.global_options, Table.empty(), fn {_, option}, flags ->
        Table.add_row(flags, [Options.format_name(option, true), Options.format_help(option)])
      end)

    flags =
      Enum.reduce(Command.options(command), flags, fn option, flags ->
        Table.add_row(flags, [Options.format_name(option, true), Options.format_help(option)])
      end)

    Document.line(doc, "")
    |> Document.section_head(@global_option_section_name)
    |> Document.table(flags)
  end
end
