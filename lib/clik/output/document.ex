defmodule Clik.Output.Document do
  alias Clik.Output.Text

  @enforce_keys [:entries]
  defstruct entries: []

  @type doc_entries :: [] | [Text.t()]
  @type t :: %__MODULE__{
          entries: doc_entries()
        }

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
