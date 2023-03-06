defmodule Clik.TableRenderTest do
  use ExUnit.Case, async: false

  alias Clik.{Platform, Renderable}
  alias Clik.Output.Table

  test "2 column table" do
    t =
      Table.empty()
      |> Table.add_row(["abc", "def"])
      |> Table.add_row(["ghi", "jkl"])

    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/table_3.txt")
    Renderable.render(t, fd)
    assert {"", expected} == StringIO.contents(fd)
  end

  test "2 column table with headers" do
    t =
      Table.empty(2, ["A", "B"])
      |> Table.add_row(["how", "now"])
      |> Table.add_row(["brown", "cow"])

    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/table_1.txt")
    Renderable.render(t, fd)
    assert {"", expected} == StringIO.contents(fd)
  end

  test "2 column table with headers, padded row" do
    t =
      Table.empty(2, ["A", "B"])
      |> Table.add_row(["hello"])
      |> Table.add_row(["hello", "world"])

    refute Table.empty?(t)
    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/table_2.txt")
    Renderable.render(t, fd)
    assert {"", expected} == StringIO.contents(fd)
  end

  test "2 column table with headers, narrow terminal" do
    Application.put_env(:clik, :tty_utility, Path.absname("test/support/scripts/small_term.sh"))
    on_exit(fn -> Application.delete_env(:clik, :tty_utility) end)
    assert 40 == Platform.terminal_width()
    long_row = for _ <- 1..10, do: "100000"
    short_row = for _ <- 1..10, do: "10"

    t =
      Table.empty(10)
      |> Table.add_row(long_row)
      |> Table.add_row(short_row)

    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/table_4.txt")
    Renderable.render(t, fd)
    assert {"", expected} == StringIO.contents(fd)
  end

  test "2 column table with headers, medium terminal" do
    Application.put_env(:clik, :tty_utility, Path.absname("test/support/scripts/medium_term.sh"))
    on_exit(fn -> Application.delete_env(:clik, :tty_utility) end)
    assert 80 == Platform.terminal_width()
    long_row = for _ <- 1..10, do: "10000000"
    short_row = for _ <- 1..10, do: "10"
    medium_row = for _ <- 1..10, do: "1000"

    t =
      Table.empty(10)
      |> Table.add_row(long_row)
      |> Table.add_row(short_row)
      |> Table.add_row(medium_row)

    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/table_5.txt")
    Renderable.render(t, fd)
    assert {"", expected} == StringIO.contents(fd)
  end

  test "2 column table with headers, left justified" do
    t =
      Table.empty(2, [{:left, "A"}, {:left, "B"}])
      |> Table.add_row(["hello", "world"])

    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/table_6.txt")
    Renderable.render(t, fd)
    assert {"", expected} == StringIO.contents(fd)
  end

  test "2 column table with headers, right justified" do
    t =
      Table.empty(2, [{:right, "A"}, {:right, "B"}])
      |> Table.add_row(["hello", "world"])

    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/table_7.txt")
    Renderable.render(t, fd)
    assert {"", expected} == StringIO.contents(fd)
  end

  test "2 column table with headers, centered" do
    t =
      Table.empty(2, [{:center, "A"}, {:center, "B"}])
      |> Table.add_row(["hello", "world"])

    {:ok, fd} = StringIO.open("")
    expected = File.read!("test/data/table_8.txt")
    Renderable.render(t, fd)
    assert {"", expected} == StringIO.contents(fd)
  end
end
