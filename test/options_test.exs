defmodule Clik.OptionsTest do
  use ExUnit.Case, async: true
  alias Clik.{Options, Option}

  describe "simple data type parsing" do
    test "integers" do
      {:ok, opt} = Option.new(:verbose, type: :integer, short: :v)
      {:ok, {parsed, _}} = Options.parse(["--verbose", "5"], [opt])
      assert [verbose: 5] == parsed
    end

    test "floats" do
      {:ok, opt} = Option.new(:intensity, type: :float, short: :i)
      {:ok, {parsed, _}} = Options.parse(["-i", "3.1415"], [opt])
      assert [intensity: 3.1415] == parsed
    end

    test "booleans" do
      {:ok, opt} = Option.new(:debug, type: :boolean)
      {:ok, {parsed, _}} = Options.parse(["--debug"], [opt])
      assert [debug: true] == parsed
      {:ok, {parsed, _}} = Options.parse(["--no-debug"], [opt])
      assert [debug: false] == parsed
    end

    test "strings" do
      {:ok, opt} = Option.new(:dir, type: :string)
      {:ok, {parsed, _}} = Options.parse(["--dir", "foo/bar"], [opt])
      assert [dir: "foo/bar"] == parsed
    end
  end

  describe "required / optional options" do
    test "missing required option returns an error" do
      opts = [
        Option.new!(:dir, type: :string, required: true),
        Option.new!(:verbose, type: :boolean)
      ]

      assert {:error, {:missing_option, :dir}} == Options.parse(["--verbose"], opts)
    end

    test "optional options are parsed if present" do
      opts = [
        Option.new!(:verbose, type: :boolean, short: :v),
        Option.new!(:url, type: :string, required: true)
      ]

      {:ok, {parsed, _}} = Options.parse(["--url", "https://example.com"], opts)
      assert Keyword.get(parsed, :url) == "https://example.com"
      assert Keyword.get(parsed, :verbose) == false
      {:ok, {parsed, _}} = Options.parse(["-v", "--url", "https://example.com"], opts)
      assert Keyword.get(parsed, :verbose) == true
      assert Keyword.get(parsed, :url) == "https://example.com"
    end
  end

  describe "bad option types return or raise errors" do
    test "bad type returns error tuple" do
      assert {:error, :badarg} == Option.new(:foo, type: :struct)
    end

    test "bad type raises error" do
      assert_raise ArgumentError, fn -> Option.new!(:foo, type: :tuple) end
    end
  end
end
