defmodule Clik.Output.Platform do
  @windows_platform [:nt, :win32]

  def eol_char() do
    case :os.type() do
      {:unix, _} ->
        "\n"

      {os_kind, _} when os_kind in @windows_platform ->
        "\r\n"
    end
  end
end
