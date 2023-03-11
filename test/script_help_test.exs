defmodule Clik.ScriptHelpTest do
  use ExUnit.Case, async: true

  alias Clik.{Command, Configuration, Option, Renderable}
  alias Clik.Output.HelpFormatter

  test "config w/script help, no global options, no commands" do
    config = Configuration.new("Hello there!")
    doc = HelpFormatter.script_help(config)
    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/formatted_help_1.txt")
    Renderable.render(doc, fd)
    assert {"", expected} == StringIO.contents(fd)
  end

  test "config w/script help, global options, no commands" do
    config =
      Configuration.new("Hello there!")
      |> Configuration.add_global_option!(
        Option.new!(:dry_run, type: :boolean, help: "Do not update")
      )

    doc = HelpFormatter.script_help(config)
    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/formatted_help_2.txt")
    Renderable.render(doc, fd)
    assert {"", expected} == StringIO.contents(fd)
  end

  test "config, no script help, no global options, no commands" do
    config = Configuration.new()
    doc = HelpFormatter.script_help(config)
    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/formatted_help_3.txt")
    Renderable.render(doc, fd)
    assert {"", expected} == StringIO.contents(fd)
  end

  test "config, no script help, global options, no commands" do
    config =
      Configuration.new()
      |> Configuration.add_global_option!(
        Option.new!(:dry_run, type: :boolean, help: "Do not update", short: :d, long: nil)
      )

    doc = HelpFormatter.script_help(config)
    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/formatted_help_4.txt")
    Renderable.render(doc, fd)
    assert {"", expected} == StringIO.contents(fd)
  end

  test "config, no script help, global options, 1 command" do
    config =
      Configuration.new()
      |> Configuration.add_global_option!(
        Option.new!(:dry_run, type: :boolean, help: "Do not update", short: :d)
      )
      |> Configuration.add_global_option!(Option.new!(:secret, type: :string, hidden: true))
      |> Configuration.add_command!(Command.new!(:bar, Clik.Test.BarCommand))

    doc = HelpFormatter.script_help(config)
    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/formatted_help_5.txt")
    Renderable.render(doc, fd)
    assert {"", expected} == StringIO.contents(fd)
  end

  test "config, no script help, no global options, 1 command" do
    config =
      Configuration.new()
      |> Configuration.add_command!(Command.new!(:bar, Clik.Test.BarCommand))

    doc = HelpFormatter.script_help(config)
    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/formatted_help_6.txt")
    Renderable.render(doc, fd)
    assert {"", expected} == StringIO.contents(fd)
  end

  test "config, script help, global options, multiple commands" do
    config =
      Configuration.new("Hello there!")
      |> Configuration.add_command!(Command.new!(:bar, Clik.Test.BarCommand))
      |> Configuration.add_command!(Command.new!(:hello, Clik.Test.HelloWorldCommand))
      |> Configuration.add_global_option!(Option.new!(:dry_run, type: :boolean))

    doc = HelpFormatter.script_help(config)
    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/formatted_help_7.txt")
    Renderable.render(doc, fd)
    assert {"", expected} == StringIO.contents(fd)
  end
end
