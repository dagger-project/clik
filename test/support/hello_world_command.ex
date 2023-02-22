defmodule Clik.Test.HelloWorldCommand do
  use Clik.Command, stubs: false

  def options() do
    [Option.new!(:verbose, type: :count)]
  end

  def arguments(), do: []

  def help_text(), do: "Says hello to the world"

  def run(_env), do: :ok
end
