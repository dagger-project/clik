defmodule Clik.CommandTest do
  use ExUnit.Case, async: true
  alias Clik.Command
  alias Clik.{DoNothingCommand, ShowHelpCommand}

  describe "command dispatch" do
    test "locate named command based on CLI argument" do
      cmd = DoNothingCommand.new(:test)
      {:ok, commands} = Command.register(cmd, %{})
      assert :ok == Clik.run("command_test", ["test"], commands)
    end

    test "display basic help" do
      cmd = ShowHelpCommand.new(:help)
      {:ok, commands} = Command.register(cmd, %{})
      output = File.open!("blah", [:ram, :read, :write, :binary])
      assert :ok == Clik.run("command_test", ["help"], commands, output)
      assert {:ok, 0} == :file.position(output, :bof)
      assert {:ok, "Usage: command_test\nDisplay help"} == :file.read(output, 1024)
    end
  end
end
