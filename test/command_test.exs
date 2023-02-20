defmodule Clik.CommandTest do
  use ExUnit.Case, async: true
  alias Clik.Command
  alias Clik.{AddCommand, DoNothingCommand, RequiredCommand, ShowHelpCommand}

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

    test "runs named command" do
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

  describe "option handling" do
    test "errors on missing required option" do
      cmd = RequiredCommand.new(:default)
      {:ok, cmds} = Command.register(cmd, %{})
      output = File.open!("d", @ram_file)
      err_output = File.open!("e", @ram_file)
      assert :error == Clik.run("command_test", [], cmds, output, err_output)
      assert {:ok, 0} == :file.position(err_output, :bof)
      assert {:ok, "Required option --required is missing\n"} == :file.read(err_output, 1024)
    end
  end

  describe "help display" do
    test "display basic help" do
      cmd = ShowHelpCommand.new(:help)
      {:ok, commands} = Command.register(cmd, %{})
      output = File.open!("b", @ram_file)
      assert :ok == Clik.run("command_test", ["help"], commands, output)
      assert {:ok, 0} == :file.position(output, :bof)
      assert {:ok, "Usage: command_test help\n\nDisplay help\n"} == :file.read(output, 1024)
    end
  end
end
