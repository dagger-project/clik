defmodule Clik.Output.Formatters.CommandHelp do
  alias Clik.{Command, Platform}
  alias Clik.Output.{Document, Table}
  alias Clik.Output.Formatters.Options

  @global_option_section_name "Global options"
  @command_option_section_name "Command options"

  def format(config, command, doc) do
    help = Command.help_text(command)

    doc =
      if help == "" do
        doc
      else
        Document.line(doc, help)
      end

    doc = Document.text(doc, "USAGE: #{Platform.script_name()} #{command.name}")

    global_options =
      Enum.map(config.global_options, fn {_key, option} -> Options.format_name(option) end)
      |> Enum.join(" ")

    command_options =
      Enum.map(Command.options(command), fn option -> Options.format_name(option) end)
      |> Enum.join(" ")

    doc = Document.line(doc, " #{global_options} #{command_options}")

    global_flags =
      Enum.reduce(config.global_options, Table.empty(), fn {_, option}, flags ->
        Table.add_row(flags, [Options.format_name(option, true), Options.format_help(option)])
      end)

    doc =
      if Table.empty?(global_flags) do
        doc
      else
        Document.line(doc, "")
        |> Document.section_head(@global_option_section_name)
        |> Document.table(global_flags)
      end

    command_flags =
      Enum.reduce(Command.options(command), Table.empty(), fn option, flags ->
        Table.add_row(flags, [Options.format_name(option, true), Options.format_help(option)])
      end)

    if Table.empty?(command_flags) do
      doc
    else
      Document.line(doc, "")
      |> Document.section_head(@command_option_section_name)
      |> Document.table(command_flags)
    end
  end
end
