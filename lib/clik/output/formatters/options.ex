defmodule Clik.Output.Formatters.Options do
  def format_help(option) do
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

  def format_name(option, full \\ false)

  def format_name(option, false) do
    if option.short != nil do
      " -#{option.short}"
    else
      " --#{format_long_name(option.long)}"
    end
  end

  def format_name(option, true) do
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
end
