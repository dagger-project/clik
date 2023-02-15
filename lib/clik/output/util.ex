defmodule Clik.Output.Util do
  require Logger

  @windows [:nt, :win32]
  @unix_cmd "tput"
  @default_width 80

  def term_width() do
    {os_type, _} = :os.type()
    term_width(os_type)
  end

  def os_break() do
    case :os.type() do
      {:unix, _} ->
        "\n"

      {os_kind, _} when os_kind in @windows ->
        "\r\n"
    end
  end

  defp term_width(:unix) do
    case System.find_executable(@unix_cmd) do
      nil ->
        Logger.warn("tput command not found. Defaulting to #{@default_width} columns.")
        @default_width

      path ->
        case System.cmd(path, ["cols"], []) do
          {width, 0} ->
            String.trim(width) |> String.to_integer()

          {_, err} ->
            Logger.warn("tput failed (error: #{err}). Defaulting to #{@default_width} columns.")
            @default_width
        end
    end
  end

  defp term_width(os_kind) when os_kind in @windows do
    @default_width
  end
end
