defmodule Clik.Test.BarCommand do
  use Clik.Command

  def options() do
    [
      Option.new!(:foo, required: true)
    ]
  end

  def run(_env), do: :ok
end
