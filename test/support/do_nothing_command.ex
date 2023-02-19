defmodule Clik.DoNothingCommand do
  use Clik.Command

  def help_text(), do: "Test command"

  def handle(invocation) do
    doc =
      Document.empty()
      |> Document.line("ok")

    CommandInvocation.puts(invocation, :out, doc)
  end
end
