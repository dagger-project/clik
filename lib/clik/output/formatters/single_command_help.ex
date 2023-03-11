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
      Enum.reduce(config.global_options, [], fn {_key, option}, acc ->
        if !option.hidden do
          [Options.format_name(option) | acc]
        else
          acc
        end
      end)

    options =
      Enum.reduce(Command.options(command), options, fn {_, option}, acc ->
        if !option.hidden do
          [Options.format_name(option) | acc]
        else
          acc
        end
      end)
      |> Enum.join("")

    doc = Document.line(doc, options)

    flags =
      Enum.reduce(config.global_options, Table.empty(), fn {_, option}, flags ->
        if !option.hidden do
          Table.add_row(flags, [Options.format_name(option, true), Options.format_help(option)])
        else
          flags
        end
      end)

    flags =
      Enum.reduce(Command.options(command), flags, fn {_, option}, flags ->
        if !option.hidden do
          Table.add_row(flags, [Options.format_name(option, true), Options.format_help(option)])
        else
          flags
        end
      end)

    Document.line(doc, "")
    |> Document.section_head(@global_option_section_name)
    |> Document.table(flags)
  end
end
