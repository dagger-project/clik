defmodule Clik.DoNothingCommand do
  use Clik.Command

  def help_text(), do: "Test command"

  def handle(_invocation), do: :ok
end
