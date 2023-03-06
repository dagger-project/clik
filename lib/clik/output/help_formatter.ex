defmodule Clik.Output.HelpFormatter do
  alias Clik.{Command, Configuration, Platform}
  alias Clik.Output.{Document, Table}

  @global_option_section_name "Global options"
  @cmd_option_section_name "Command options"

  @spec script_help(Configuration.t()) :: Document.t()
  def script_help(config) do
    doc =
      if config.script_help != nil do
        Document.empty()
        |> Document.line(config.script_help)
        |> Document.line("")
      else
        Document.empty()
      end

    doc = Document.text(doc, "USAGE: #{Platform.script_name()}")

    command_count =
      Enum.count(config.commands) +
        if Configuration.has_default?(config) do
          -1
        else
          0
        end

    doc =
      if command_count > 0 do
        Document.text(doc, " <cmd> ")
      else
        doc
      end

    options =
      Enum.map(config.global_options, fn {_key, option} -> format_option(option) end)
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
        Table.add_row(flags, [format_option(option, true), format_option_help(option)])
      end)

    if Table.size(flags) > 0 do
      Document.line(doc, "")
      |> Document.section_head(@global_option_section_name)
      |> Document.table(flags)
    else
      doc
    end
  end

  def command_help(config, cmd_name) do
    cmd = Map.fetch!(config.commands, cmd_name)

    doc = Document.empty()
    help = Command.help_text(cmd)

    doc =
      if help == "" do
        doc
      else
        Document.line(doc, help)
      end

    doc = Document.text(doc, "USAGE: #{Platform.script_name()} #{cmd.name}")

    global_options =
      Enum.map(config.global_options, fn {_key, option} -> format_option(option) end)
      |> Enum.join(" ")

    cmd_options =
      Enum.map(Command.options(cmd), fn option -> format_option(option) end)
      |> Enum.join(" ")

    doc = Document.line(doc, " #{global_options} #{cmd_options}")

    global_flags =
      Enum.reduce(config.global_options, Table.empty(), fn {_, option}, flags ->
        Table.add_row(flags, [format_option(option, true), format_option_help(option)])
      end)

    doc =
      if Table.empty?(global_flags) do
        doc
      else
        Document.line(doc, "")
        |> Document.line(@global_option_section_name)
        |> Document.line(String.duplicate("-", String.length(@global_option_section_name)))
        |> Document.table(global_flags)
      end

    cmd_flags =
      Enum.reduce(Command.options(cmd), Table.empty(), fn option, flags ->
        Table.add_row(flags, [format_option(option, true), format_option_help(option)])
      end)

    if Table.empty?(cmd_flags) do
      doc
    else
      Document.line(doc, "")
      |> Document.section_head(@cmd_option_section_name)
      |> Document.table(cmd_flags)
    end
  end

  defp format_option_help(option) do
    if option.help != nil do
      if option.default != nil do
        option.help <> " (default: #{option.default})"
      else
        option.help
      end
    else
      if option.default != nil do
        "default: #{option.default}"
      else
        ""
      end
    end
  end

  defp format_option(option, full \\ false)

  defp format_option(option, false) do
    if option.short != nil do
      " -#{option.short}"
    else
      " --#{format_long_name(option.long)}"
    end
  end

  defp format_option(option, true) do
    short_option =
      if option.short != nil do
        "-#{option.short}"
      end

    long_option =
      if option.long != nil do
        "--#{format_long_name(option.long)}"
      end

    text =
      cond do
        short_option != nil and long_option != nil ->
          " #{short_option},#{long_option}"

        short_option != nil ->
          " #{short_option}"

        long_option != nil ->
          " #{long_option}"
      end

    updated =
      case option_placeholder(option) do
        nil ->
          text

        placeholder ->
          text <> " " <> placeholder
      end

    String.trim_leading(updated)
  end

  defp format_long_name(name) do
    Atom.to_string(name)
    |> String.replace("_", "-")
  end

  defp option_placeholder(option) do
    case option.type do
      :integer ->
        "<n>"

      :float ->
        "<f>"

      :string ->
        "<str>"

      _ ->
        nil
    end
  end

  defp available_commands(config) do
    Enum.map(Map.keys(config.commands), &Atom.to_string(&1))
    |> Enum.join(",")
  end
end
