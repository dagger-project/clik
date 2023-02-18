defmodule Clik.ShowHelpCommand do
  use Clik.Command

  def help_text(), do: "Display help"

  def handle(_invocation), do: :help
end
