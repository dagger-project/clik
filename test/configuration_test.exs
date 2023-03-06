defmodule Clik.ConfigurationTest do
  use ExUnit.Case, async: true
  alias Clik.DuplicateCommandError
  alias Clik.{DuplicateCommandError, DuplicateOptionError, UnknownCommandError}
  alias Clik.{Command, Option, Configuration}

  describe "registering commands" do
    test "empty configuration" do
      assert {:ok, config} =
               Configuration.new()
               |> Configuration.add_command(
                 Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
               )

      # Must account for built-in global --help option
      assert 1 == Enum.count(config.global_options)
      assert 1 == Enum.count(config.commands)
    end

    test "configuration with a global option" do
      assert {:ok, config} =
               Configuration.new()
               |> Configuration.add_global_option(Option.new!(:retry, type: :boolean))

      config =
        Configuration.add_command!(
          config,
          Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
        )

      # Merged set of global and command options
      assert [:help, :retry, :verbose] ==
               Configuration.options!(config, :hello_world) |> Map.keys() |> Enum.sort()
    end

    test "configuration with duplicate global options raises error" do
      opt = Option.new!(:retry, type: :boolean)

      assert_raise DuplicateOptionError, fn ->
        Configuration.new()
        |> Configuration.add_global_option!(opt)
        |> Configuration.add_global_option!(opt)
      end
    end

    test "configuration and command with conflicting options" do
      assert {:ok, config} =
               Configuration.new()
               |> Configuration.add_global_option(Option.new!(:verbose, type: :boolean))

      assert {:error, :duplicate_option, option} =
               Configuration.add_command(
                 config,
                 Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
               )

      assert :verbose == option.name
    end

    test "configuration and command with conflicting options raises error" do
      assert {:ok, config} =
               Configuration.new()
               |> Configuration.add_global_option(Option.new!(:verbose, type: :boolean))

      assert_raise DuplicateOptionError, fn ->
        Configuration.add_command!(
          config,
          Command.new!(:hello_world, Clik.Test.HelloWorldCommand)
        )
      end
    end

    test "look up command by name" do
      assert {:ok, config} =
               Configuration.new()
               |> Configuration.add_command(Command.new!(:hello, Clik.Test.HelloWorldCommand))

      assert {:ok, cmd} = Configuration.command(config, :hello)
      assert :hello == cmd.name
      assert cmd == Configuration.command!(config, :hello)
    end

    test "look up unknown command by name" do
      assert {:ok, config} =
               Configuration.new()
               |> Configuration.add_command(Command.new!(:hello, Clik.Test.HelloWorldCommand))

      assert {:error, :unknown_command} == Configuration.command(config, :goodbye)
      assert_raise UnknownCommandError, fn -> Configuration.command!(config, :goodbye) end
    end

    test "add redundant command" do
      cmd = Command.new!(:hello, Clik.Test.HelloWorldCommand)

      assert {:ok, config} =
               Configuration.new()
               |> Configuration.add_command(cmd)

      assert {:error, :duplicate_command} == Configuration.add_command(config, cmd)
      assert_raise DuplicateCommandError, fn -> Configuration.add_command!(config, cmd) end
    end
  end

  describe "options" do
    test "retrieve command options" do
      {:ok, config} =
        Configuration.add_command(
          Configuration.new(),
          Command.new!(:hello, Clik.Test.HelloWorldCommand)
        )

      {:ok, config} =
        Configuration.add_global_option(config, Option.new!(:dry_run, type: :boolean))

      {:ok, options} = Configuration.options(config, :hello)
      assert Map.has_key?(options, :dry_run)
      assert Map.has_key?(options, :verbose)
    end

    test "retrieve options for unknown command" do
      assert {:error, :unknown_command} == Configuration.options(Configuration.new(), :hello)

      assert_raise UnknownCommandError, fn ->
        Configuration.options!(Configuration.new(), :hello)
      end
    end

    test "prepare global options for parsing" do
      config =
        Configuration.add_command!(
          Configuration.new(),
          Command.new!(:hello, Clik.Test.HelloWorldCommand)
        )
        |> Configuration.add_global_option!(Option.new!(:dry_run, type: :boolean, short: :d))

      assert {:ok,
              [strict: [help: :boolean, dry_run: :boolean], aliases: [h: :help, d: :dry_run]]} ==
               Configuration.prepare(config)
    end

    test "prepare command options for parsing" do
      config =
        Configuration.add_command!(
          Configuration.new(),
          Command.new!(:hello, Clik.Test.HelloWorldCommand)
        )
        |> Configuration.add_global_option!(Option.new!(:dry_run, type: :boolean, short: :d))

      assert {:ok,
              [
                {:strict, [verbose: :count, help: :boolean, dry_run: :boolean]},
                {:aliases, [h: :help, d: :dry_run]}
              ]} ==
               Configuration.prepare(config, :hello)
    end

    test "prepare options for unknown command" do
      assert {:error, :unknown_command} == Configuration.prepare(Configuration.new(), :hello)
    end
  end
end
