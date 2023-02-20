defmodule Clik.RequiredCommand do
  use Clik.Command

  def help_text(), do: "Requires an option"

  def options() do
    [Option.new!(:required, required: true, short: :r)]
  end

  def handle(_invocation), do: :ok
end
