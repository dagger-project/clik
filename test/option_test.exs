defmodule Clik.OptionTest do
  use ExUnit.Case, async: true

  alias Clik.Option

  describe "creating options" do
    test "defaults are used" do
      {:ok, opt} = Option.new(:foo)
      assert nil == opt.default
      assert "" == opt.help
      assert false == opt.hidden
      assert :foo == opt.long
      assert false == opt.required
      assert nil == opt.short
      assert :string == opt.type
    end

    test "override defaults" do
      {:ok, opt} = Option.new(:foo, help: "Foo command")
      assert nil == opt.default
      assert "Foo command" == opt.help
      assert false == opt.hidden
      assert :foo == opt.long
      assert false == opt.required
      assert nil == opt.short
      assert :string == opt.type
    end

    test "override defaults using new!" do
      opt = Option.new!(:foo, help: "Foo command")
      assert nil == opt.default
      assert "Foo command" == opt.help
      assert false == opt.hidden
      assert :foo == opt.long
      assert false == opt.required
      assert nil == opt.short
      assert :string == opt.type
    end

    test "option type and default value mismatch" do
      # default string type
      assert {:error, :badarg} == Option.new(:foo, default: 1)
      assert {:error, :badarg} == Option.new(:foo, type: :boolean, default: :something)
      assert {:error, :badarg} == Option.new(:foo, type: :count, default: 0.0)
      assert {:error, :badarg} == Option.new(:foo, type: :float, default: false)
      assert {:error, :badarg} == Option.new(:foo, type: :integer, default: 1.23)
    end

    test "option type and default value match" do
      # default string type
      assert {:ok, _} = Option.new(:foo, default: "hello")
      assert {:ok, _} = Option.new(:foo, type: :boolean, default: true)
      assert {:ok, _} = Option.new(:foo, type: :count, default: 0)
      assert {:ok, _} = Option.new(:foo, type: :float, default: 3.14)
      assert {:ok, _} = Option.new(:foo, type: :integer, default: 5)
    end

    test "new! raises error" do
      assert_raise ArgumentError, fn -> Option.new!(:foo, default: 1) end
      assert_raise ArgumentError, fn -> Option.new!(:foo, type: :boolean, default: :something) end
      assert_raise ArgumentError, fn -> Option.new!(:foo, type: :count, default: 0.0) end
      assert_raise ArgumentError, fn -> Option.new!(:foo, type: :float, default: false) end
      assert_raise ArgumentError, fn -> Option.new!(:foo, type: :integer, default: 1.23) end
    end

    test "redundant use of required and default" do
      assert {:error, :badarg} == Option.new(:foo, required: true, default: "abc")
    end

    test "unknown option type" do
      assert {:error, :badarg} == Option.new(:foo, type: :stringy)
    end

    test "bad option help" do
      assert {:error, :badarg} == Option.new(:foo, help: 123)
    end

    test "short name is too long" do
      assert {:error, :badarg} == Option.new(:foo, short: :fo)
    end

    test "short name matches long name" do
      assert {:error, :badarg} == Option.new(:f, short: :f)
    end
  end
end
