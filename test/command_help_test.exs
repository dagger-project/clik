defmodule Clik.CommandHelpTest do
  use ExUnit.Case, async: true

  alias Clik.{Command, Configuration, Option, Renderable}
  alias Clik.Output.HelpFormatter

  test "config w/default command only" do
    config =
      Configuration.new("Hello there!")
      |> Configuration.add_command!(Command.new!(:default, Clik.Test.HelloWorldCommand))

    doc = HelpFormatter.command_help(config, :default)
    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/formatted_help_8.txt")
    Renderable.render(doc, fd)
    assert {"", expected} == StringIO.contents(fd)
  end
end
