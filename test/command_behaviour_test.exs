defmodule Clik.CommandBehaviourTest do
  use ExUnit.Case, async: true

  require Clik.Command
  alias Clik.{Command, Registry}

  test "basic getters" do
    cmd = Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
    options = Command.options(cmd)
    assert 1 == length(options)
    assert "Says hello to the world" == Command.help_text(cmd)
  end

  test "execute a command" do
    cmd = Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
    assert :ok == Command.run(cmd, %Clik.CommandEnvironment{})
  end

  test "execute a command w/high-level interface" do
    cmd = Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
    registry = Registry.add_command!(%Registry{}, cmd)
    assert :ok == Clik.run(registry, ["hello_world"])
    assert {:error, :no_default} == Clik.run(registry, [])
  end

  test "execute a command w/high-level interface and bad command name" do
    cmd = Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
    registry = Registry.add_command!(%Registry{}, cmd)
    assert {:error, {:unknown_command, "hello"}} == Clik.run(registry, ["hello"])
    assert {:error, :no_default} == Clik.run(registry, [])
  end

  test "execute a command w/high-level interface and default command" do
    cmd = Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
    default = Command.new!(:default, Clik.Test.HelloWorldCommand)
    registry = Registry.add_command!(%Registry{}, cmd) |> Registry.add_command!(default)
    assert :ok == Clik.run(registry, ["hello_world"])
    assert :ok == Clik.run(registry, [])
  end

  test "execute command w/high-level interface and missing required option" do
    registry = Registry.add_command!(%Registry{}, Command.new!(:bar, Clik.Test.BarCommand))
    assert {:error, {:missing_option, :foo}} == Clik.run(registry, ["bar"])
  end

  test "execute command w/high-level interface and required option" do
    registry = Registry.add_command!(%Registry{}, Command.new!(:bar, Clik.Test.BarCommand))
    assert :ok == Clik.run(registry, ["bar", "--foo", "abc"])
  end

  test "execute command w/high-level interface and unknown options" do
    registry = Registry.add_command!(%Registry{}, Command.new!(:bar, Clik.Test.BarCommand))

    assert {:error, {:unknown_options, ["--bar", "--baz"]}} ==
             Clik.run(registry, ["bar", "--foo", "abc", "--bar", "--baz"])
  end

  test "execute command w/high-level interface and default options" do
    registry = Registry.add_command!(%Registry{}, Command.new!(:default, Clik.Test.BazCommand))

    assert :ok == Clik.run(registry, ["baz", "--foo", "abc"])
  end

  test "bad args are caught" do
    assert {:error, :badarg} == Command.new(:hello_world, nil)
    assert {:error, :badarg} == Command.new(nil, Clik.Test.HelloWorldCommand)
    assert_raise ArgumentError, fn -> Command.new!(:hello_world, nil) end
    assert_raise ArgumentError, fn -> Command.new!(nil, Clik.Test.HelloWorldCommand) end
  end
end
