defmodule Clik.RegistryTest do
  use ExUnit.Case, async: true
  alias Clik.DuplicateCommandError
  alias Clik.{DuplicateCommandError, DuplicateOptionError, UnknownCommandError}
  alias Clik.{Command, Option, Registry}

  describe "registering commands" do
    test "empty registry" do
      assert {:ok, registry} =
               %Registry{}
               |> Registry.add_command(Command.new!(:hello_world, Clik.Test.HelloWorldCommand))

      assert 0 == Enum.count(registry.global_options)
      assert 1 == Enum.count(registry.commands)
    end

    test "registry with a global option" do
      assert {:ok, registry} =
               %Registry{} |> Registry.add_global_option(Option.new!(:retry, type: :boolean))

      registry =
        Registry.add_command!(registry, Command.new!(:hello_world, Clik.Test.HelloWorldCommand))

      # Merged set of global and command options
      assert [:retry, :verbose] ==
               Registry.options!(registry, :hello_world) |> Map.keys() |> Enum.sort()
    end

    test "registry with duplicate global options raises error" do
      opt = Option.new!(:retry, type: :boolean)

      assert_raise DuplicateOptionError, fn ->
        %Registry{} |> Registry.add_global_option!(opt) |> Registry.add_global_option!(opt)
      end
    end

    test "registry and command with conflicting options" do
      assert {:ok, registry} =
               %Registry{} |> Registry.add_global_option(Option.new!(:verbose, type: :boolean))

      assert {:error, :duplicate_option, option} =
               Registry.add_command(
                 registry,
                 Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
               )

      assert :verbose == option.name
    end

    test "registry and command with conflicting options raises error" do
      assert {:ok, registry} =
               %Registry{} |> Registry.add_global_option(Option.new!(:verbose, type: :boolean))

      assert_raise DuplicateOptionError, fn ->
        Registry.add_command!(registry, Command.new!(:hello_world, Clik.Test.HelloWorldCommand))
      end
    end

    test "look up command by name" do
      assert {:ok, registry} =
               %Registry{}
               |> Registry.add_command(Command.new!(:hello, Clik.Test.HelloWorldCommand))

      assert {:ok, cmd} = Registry.command(registry, :hello)
      assert :hello == cmd.name
      assert cmd == Registry.command!(registry, :hello)
    end

    test "look up unknown command by name" do
      assert {:ok, registry} =
               %Registry{}
               |> Registry.add_command(Command.new!(:hello, Clik.Test.HelloWorldCommand))

      assert {:error, :unknown_command} == Registry.command(registry, :goodbye)
      assert_raise UnknownCommandError, fn -> Registry.command!(registry, :goodbye) end
    end

    test "add redundant command" do
      cmd = Command.new!(:hello, Clik.Test.HelloWorldCommand)

      assert {:ok, registry} =
               %Registry{}
               |> Registry.add_command(cmd)

      refute Registry.has_default?(registry)
      assert {:error, :duplicate_command} == Registry.add_command(registry, cmd)
      assert_raise DuplicateCommandError, fn -> Registry.add_command!(registry, cmd) end
    end

    test "add default command" do
      cmd = Command.new!(:default, Clik.Test.HelloWorldCommand)

      assert {:ok, registry} =
               %Registry{}
               |> Registry.add_command(Command.new!(:hello, Clik.Test.HelloWorldCommand))

      assert {:ok, registry} = Registry.add_command(registry, cmd)
      assert Registry.has_default?(registry)
    end
  end

  describe "options" do
    test "retrieve command options" do
      {:ok, registry} =
        Registry.add_command(%Registry{}, Command.new!(:hello, Clik.Test.HelloWorldCommand))

      {:ok, registry} =
        Registry.add_global_option(registry, Option.new!(:dry_run, type: :boolean))

      {:ok, options} = Registry.options(registry, :hello)
      assert Map.has_key?(options, :dry_run)
      assert Map.has_key?(options, :verbose)
    end

    test "retrieve options for unknown command" do
      assert {:error, :unknown_command} == Registry.options(%Registry{}, :hello)
      assert_raise UnknownCommandError, fn -> Registry.options!(%Registry{}, :hello) end
    end

    test "prepare global options for parsing" do
      registry =
        Registry.add_command!(%Registry{}, Command.new!(:hello, Clik.Test.HelloWorldCommand))
        |> Registry.add_global_option!(Option.new!(:dry_run, type: :boolean, short: :d))

      assert {:ok, [strict: [dry_run: :boolean], aliases: [d: :dry_run]]} ==
               Registry.prepare(registry)
    end

    test "prepare command options for parsing" do
      registry =
        Registry.add_command!(%Registry{}, Command.new!(:hello, Clik.Test.HelloWorldCommand))
        |> Registry.add_global_option!(Option.new!(:dry_run, type: :boolean, short: :d))

      assert {:ok, [{:strict, [verbose: :count, dry_run: :boolean]}, {:aliases, [d: :dry_run]}]} ==
               Registry.prepare(registry, :hello)
    end

    test "prepare options for unknown command" do
      assert {:error, :unknown_command} == Registry.prepare(%Registry{}, :hello)
    end
  end
end
