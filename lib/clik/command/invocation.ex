defmodule Clik.Command.Invocation do
  alias Clik.Renderable
  alias Clik.Output
  @type t :: %__MODULE__{}
  @type dest :: :out | :err
  defstruct [:options, :arguments, :output, :err_output]

  @spec puts(t(), dest(), Clik.Renderable.t()) :: :ok
  def puts(invocation, :out, data) do
    Output.puts(invocation.output, Renderable.render(data))
  end

  def puts(invocation, :err, data) do
    Output.puts(invocation.err_output, Renderable.render(data))
  end
end
