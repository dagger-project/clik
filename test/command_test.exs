defmodule Clik.CommandTest do
  use ExUnit.Case, async: true
  alias Clik.Command
  alias Clik.{AddCommand, DoNothingCommand, ShowHelpCommand}

  @ram_file [:ram, :read, :write, :binary]

  describe "command dispatch" do
    test "locate named command based on CLI argument" do
      cmd = DoNothingCommand.new(:test)
      {:ok, commands} = Command.register(cmd, %{})
      output = File.open!("a", @ram_file)
      assert :ok == Clik.run("command_test", ["test"], commands, output)
      assert {:ok, 0} == :file.position(output, :bof)
      assert {:ok, "ok\n"} == :file.read(output, 1024)
    end

    test "display basic help" do
      cmd = ShowHelpCommand.new(:help)
      {:ok, commands} = Command.register(cmd, %{})
      output = File.open!("b", @ram_file)
      assert :ok == Clik.run("command_test", ["help"], commands, output)
      assert {:ok, 0} == :file.position(output, :bof)
      assert {:ok, "Usage: command_test\nDisplay help"} == :file.read(output, 1024)
    end

    test "simple command" do
      cmd = AddCommand.new(:add)
      {:ok, commands} = Command.register(cmd, %{})
      {:ok, commands} = Command.register(cmd, :default, commands)
      output = File.open!("c", @ram_file)
      assert :ok == Clik.run("command_test", ["2", "3"], commands, output)
      assert {:ok, 0} == :file.position(output, :bof)
      assert {:ok, "5\n"} == :file.read(output, 1024)
    end

    test "runs default command with no args" do
      add = AddCommand.new(:add)
      do_nothing = DoNothingCommand.new(:nothing)
      {:ok, cmds} = Command.register(add, %{})
      {:ok, cmds} = Command.register(do_nothing, cmds)
      {:ok, cmds} = Command.register(do_nothing, :default, cmds)
      output = File.open!("c", @ram_file)
      assert :ok == Clik.run("command_test", [], cmds, output)
      assert {:ok, 0} == :file.position(output, :bof)
      assert {:ok, "ok\n"} == :file.read(output, 1024)
    end

    test "runs named command with" do
      add = AddCommand.new(:add)
      do_nothing = DoNothingCommand.new(:nothing)
      {:ok, cmds} = Command.register(add, %{})
      {:ok, cmds} = Command.register(do_nothing, cmds)
      {:ok, cmds} = Command.register(do_nothing, :default, cmds)
      output = File.open!("c", @ram_file)
      assert :ok == Clik.run("command_test", ["add", "5", "7"], cmds, output)
      assert {:ok, 0} == :file.position(output, :bof)
      assert {:ok, "12\n"} == :file.read(output, 1024)
    end
  end
end
