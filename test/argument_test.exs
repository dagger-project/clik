defmodule Clik.ArgumentTest do
  use ExUnit.Case, async: true

  alias Clik.Argument

  describe "creating arguments" do
    test "defaults are used" do
      {:ok, arg} = Argument.new(:foo)
      assert :foo == arg.name
      assert :string == arg.type
      assert false == arg.required
    end

    test "new! uses defaults" do
      arg = Argument.new!(:foo)
      assert :foo == arg.name
      assert :string == arg.type
      assert false == arg.required
    end

    test "override defaults" do
      {:ok, arg} = Argument.new(:foo, type: :integer)
      assert :foo == arg.name
      assert :integer == arg.type
      assert false == arg.required
    end

    test "override defaults using new!" do
      arg = Argument.new!(:foo, required: true)
      assert :foo == arg.name
      assert :string == arg.type
      assert true == arg.required
    end

    test "new! raises error" do
      assert_raise ArgumentError, fn -> Argument.new!(:foo, type: :stringy) end
      assert_raise ArgumentError, fn -> Argument.new!(:foo, required: :yes) end
    end

    test "unknown argument type" do
      assert {:error, :badarg} == Argument.new(:foo, type: :stringy)
    end
  end
end
