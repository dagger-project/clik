defmodule Clik.Output.Platform do
  @moduledoc false
  @windows_platform [:nt, :win32]

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
end
