defmodule Clik.TextRenderTest do
  use ExUnit.Case, async: true
  alias Clik.Renderable
  alias Clik.Output.{Text, Platform}

  test "render simple string" do
    {:ok, fd} = StringIO.open("")
    t = Text.new("this is a test", false)
    Renderable.render(t, fd)
    assert {"", "this is a test"} == StringIO.contents(fd)
  end

  test "render ANSI formatted string" do
    {:ok, fd} = StringIO.open("")
    t = Text.new(:red, "this is a warning", false)
    Renderable.render(t, fd)
    assert {"", "\e[31mthis is a warning\e[0m"} == StringIO.contents(fd)
  end

  test "render line of text" do
    {:ok, fd} = StringIO.open("")
    t = Text.new("this is a test", true)
    Renderable.render(t, fd)
    expected_text = "this is a test" <> Platform.eol_char()
    assert {"", expected_text} == StringIO.contents(fd)
  end

  test "render line of ANSI formatted text" do
    {:ok, fd} = StringIO.open("")
    t = Text.new(:yellow, "this is a test", true)
    Renderable.render(t, fd)
    expected_text = "\e[33mthis is a test\e[0m" <> Platform.eol_char()
    assert {"", expected_text} == StringIO.contents(fd)
  end

  test "render appended text entries" do
    {:ok, fd} = StringIO.open("")
    t1 = Text.new("hello, ", false)
    t2 = Text.append(t1, "world")
    Renderable.render(t2, fd)
    assert {"", "hello, world"} == StringIO.contents(fd)
  end
end
