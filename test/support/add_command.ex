defmodule Clik.AddCommand do
  use Clik.Command

  def help_text(), do: "Adds two numbers together"

  def handle(invocation) do
    [a, b] = invocation.arguments
    result = String.to_integer(a) + String.to_integer(b)
    d = Document.empty() |> Document.line(result)
    CommandInvocation.puts(invocation, :out, d)
    :ok
  end
end
