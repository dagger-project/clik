defmodule Clik.Output.Document do
  @moduledoc """
  Formatted terminal output.
  """
  alias IO.ANSI
  alias Clik.Output.Text

  @enforce_keys [:entries]
  defstruct entries: []

  @type doc_entries :: [] | [Text.t()]
  @type t :: %__MODULE__{
          entries: doc_entries()
        }

  @type code :: ANSI.ansicode() | nil

  @doc "Creates a new empty document"
  @doc since: "0.1.0"
  @spec empty() :: t()
  def empty(), do: %__MODULE__{entries: []}

  @doc "Adds a block of text to a document"
  @spec text(t(), code(), String.t()) :: t()
  def text(doc, code \\ nil, text) do
    %{doc | entries: [Text.new(code, text, false) | doc.entries]}
  end

  @doc "Add a line to a document"
  @spec line(t(), code(), bitstring()) :: t()
  def line(doc, code \\ nil, text) do
    %{doc | entries: [Text.new(code, text, true) | doc.entries]}
  end
end
