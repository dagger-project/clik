defmodule Clik.Output.Document do
  alias Clik.Output.Text
  defstruct [:entries]

  @type t :: %__MODULE__{}

  @spec new() :: t()
  def new(), do: %__MODULE__{entries: []}

  @spec text(t(), atom(), bitstring()) :: t()
  def text(doc, code \\ nil, text) do
    %{doc | entries: [Text.new(code, text, false) | doc.entries]}
  end

  @spec line(t(), atom(), bitstring()) :: t()
  def line(doc, code \\ nil, text) do
    %{doc | entries: [Text.new(code, text, true) | doc.entries]}
  end
end

defimpl Clik.Renderable, for: Clik.Output.Document do
  alias Clik.Renderable

  def render(doc, out) do
    Enum.reverse(doc.entries)
    |> Enum.reduce_while({:ok, out}, fn entry, {:ok, out} ->
      case Renderable.render(entry, out) do
        {:ok, updated} ->
          {:cont, {:ok, updated}}

        error ->
          {:halt, error}
      end
    end)
  end
end
