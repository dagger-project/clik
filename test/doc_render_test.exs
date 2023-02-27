defmodule Clik.DocRenderTest do
  use ExUnit.Case, async: true
  alias Clik.Renderable
  alias Clik.Output.Document

  test "render empty doc" do
    d = Document.empty()
    {:ok, fd} = StringIO.open("")
    assert {:ok, _} = Renderable.render(d, fd)
    assert {"", ""} == StringIO.contents(fd)
  end

  test "render doc with text" do
    d =
      Document.empty()
      |> Document.text("hello, ")
      |> Document.text("world")

    {:ok, fd} = StringIO.open("")
    assert {:ok, _} = Renderable.render(d, fd)
    assert {"", "hello, world"} == StringIO.contents(fd)
  end

  test "render doc with lines" do
    d =
      Document.empty()
      |> Document.line("hello, world!")
      |> Document.line(:green, "mwhat's up?")

    {:ok, fd} = StringIO.open("")
    assert {:ok, _} = Renderable.render(d, fd)
    assert {"", "hello, world!\n\e[32mmwhat's up?\e[0m\n"} == StringIO.contents(fd)
  end
end
