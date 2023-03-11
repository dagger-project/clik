defmodule Clik.PlatformTest do
  use ExUnit.Case, async: false

  alias Clik.Platform
  alias Clik.Test.{WindowsNTDetector, Windows32BitDetector, LinuxDetector, MacDetector}

  test "detects correct EOL sequence for supported platforms" do
    detectors = [
      [module: WindowsNTDetector, eol: "\r\n"],
      [module: Windows32BitDetector, eol: "\r\n"],
      [module: LinuxDetector, eol: "\n"],
      [module: MacDetector, eol: "\n"]
    ]

    on_exit(fn -> Application.delete_env(:clik, :tty_utility) end)

    Enum.each(detectors, fn module: mod, eol: expected_eol ->
      Application.put_env(:clik, :os_detector, mod)
      assert expected_eol == Platform.eol_char()
    end)
  end

  test "uses configured TTY utility to determine terminal width" do
    utilities = [
      [utility: "./test/support/scripts/large_term.sh", width: 170],
      [utility: "./test/support/scripts/small_term.sh", width: 40]
    ]

    on_exit(fn -> Application.delete_env(:clik, :tty_utility) end)

    Enum.each(utilities, fn utility: util, width: expected_width ->
      Application.put_env(:clik, :tty_utility, Path.absname(util))
      assert expected_width == Platform.terminal_width()
    end)
  end

  test "detects script name" do
    assert "mix" == Platform.script_name()
  end
end
