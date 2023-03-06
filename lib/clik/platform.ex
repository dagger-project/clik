defmodule Clik.Platform do
  @moduledoc false
  @windows_platform [:nt, :win32]
  @default_term_width 120

  def script_name() do
    case Path.basename(:escript.script_name()) do
      "--no-halt" ->
        "mix"

      name ->
        name
    end
  end

  def eol_char() do
    os_module = Application.get_env(:clik, :os_detector, :os)

    case os_module.type() do
      {:unix, _} ->
        "\n"

      {os_kind, _} when os_kind in @windows_platform ->
        "\r\n"
    end
  end

  def terminal_width() do
    try do
      case locate_tty_utility() do
        nil ->
          @default_term_width

        tty_utility ->
          case System.cmd(tty_utility, ["cols"]) do
            {text_width, 0} ->
              String.to_integer(String.trim(text_width))

            _ ->
              @default_term_width
          end
      end
    rescue
      ErlangError ->
        @default_term_width
    end
  end

  defp locate_tty_utility() do
    case Application.get_env(:clik, :tty_utility, nil) do
      nil ->
        case System.cmd("which", ["tput"]) do
          {path, 0} ->
            String.trim(path)

          _ ->
            nil
        end

      path ->
        path
    end
  end
end
