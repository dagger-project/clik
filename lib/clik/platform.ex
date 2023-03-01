defmodule Clik.Platform do
  @moduledoc false
  @windows_platform [:nt, :win32]
  @default_term_width 120

  def script_name() do
    Path.basename(:escript.script_name())
  end

  def eol_char() do
    case :os.type() do
      {:unix, _} ->
        "\n"

      {os_kind, _} when os_kind in @windows_platform ->
        "\r\n"
    end
  end

  def terminal_width() do
    try do
      case System.cmd("which", ["tput"]) do
        {path, 0} ->
          tput_cmd = String.trim(path)

          case System.cmd(tput_cmd, ["cols"]) do
            {text_width, 0} ->
              String.to_integer(String.trim(text_width))

            _ ->
              @default_term_width
          end

        _ ->
          @default_term_width
      end
    rescue
      ErlangError ->
        @default_term_width
    end
  end
end
