defmodule Clik.Test.BazCommand do
  use Clik.Command

  def options() do
    %{
      foo: Option.new!(:foo, required: true),
      baz: Option.new!(:baz, type: :integer, default: 100)
    }
  end

  def run(env) do
    if Keyword.get(env.options, :baz) == 100 do
      :ok
    else
      {:error, :bad_baz}
    end
  end
end
