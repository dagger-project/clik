defmodule Clik.HelpFormatterTest do
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
end
