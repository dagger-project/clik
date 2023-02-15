defmodule Clik.RenderableTest do
  use ExUnit.Case, async: true
  alias Clik.Renderable
  alias Clik.Output.{Break, Document, Text}

  describe "render supported built-in types" do
    test "render integer" do
      assert "123" == Renderable.render(123)
    end

    test "render float" do
      assert "123.456" == Renderable.render(123.456)
    end

    test "render string" do
      assert "abcd" == Renderable.render("abcd")
    end

    test "render boolean" do
      assert "true" == Renderable.render(true)
      assert "false" == Renderable.render(false)
    end
  end

  describe "render custom types" do
    test "render line break" do
      case :os.type() do
        {:unix, _} ->
          assert "\n" == Renderable.render(Break.new())
          assert "\n\n" == Renderable.render(Break.new(2))

        {win, _} when win in [:nt, :win32] ->
          assert "\r\n" == Renderable.render(Break.new())
          assert "\r\n\r\n" == Renderable.render(Break.new(2))
      end
    end

    test "render text" do
      assert "Hello, world" == Renderable.render(Text.new("Hello, world"))
      assert "\e[31mHello, world\e[0m" == Renderable.render(Text.new(:red, "Hello, world"))
    end

    test "render empty document" do
      assert "" == Renderable.render(Document.empty())
    end

    test "render document" do
      doc = Document.empty()
      doc = Document.line(doc, "HEADING") |> Document.break()
      doc = Document.line(doc, "This is a line of text.")
      assert "HEADING\n\nThis is a line of text.\n" == Renderable.render(doc)
    end

    test "render document with mixed values" do
      doc =
        Document.empty()
        |> Document.line("HEADING")
        |> Document.break()
        |> Document.line(["This is the number ", 5, "."])
        |> Document.line([true, " and ", false, " are boolean values."])

      assert "HEADING\n\nThis is the number 5.\ntrue and false are boolean values.\n" ==
               Renderable.render(doc)
    end

    test "render document with mixed values and ANSI codes" do
      doc =
        Document.empty()
        |> Document.line("HEADING")
        |> Document.break()
        |> Document.line(:green, ["This is the number ", 5, "."])
        |> Document.line([true, " and ", false, " are boolean values."])

      assert "HEADING\n\n\e[32mThis is the number 5.\e[0m\ntrue and false are boolean values.\n" ==
               Renderable.render(doc)
    end
  end
end
