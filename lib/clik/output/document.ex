defmodule Clik.Output.Document do
  @moduledoc """
  Formatted terminal output.
  """
  alias IO.ANSI
  alias Clik.Renderable
  alias Clik.Output.{Table, Text}

  @enforce_keys [:entries]
  defstruct entries: []

  @type doc_entries :: [] | [Renderable.t()]
  @type t :: %__MODULE__{
          entries: doc_entries()
        }

  @type code :: ANSI.ansicode() | nil

  @doc "Creates a new empty document"
  @doc since: "0.1.0"
  @spec empty() :: t()
  def empty(), do: %__MODULE__{entries: []}

  @doc "Adds a block of text to a document"
  @doc since: "0.1.0"
  @spec text(t(), code(), String.t()) :: t()
  def text(doc, code \\ nil, text) do
    %{doc | entries: [Text.new(code, text, false) | doc.entries]}
  end

  @doc "Add a line to a document"
  @doc since: "0.1.0"
  @spec line(t(), code(), String.t()) :: t()
  def line(doc, code \\ nil, text) do
    %{doc | entries: [Text.new(code, text, true) | doc.entries]}
  end

  @doc "Adds a section header to a document"
  @doc since: "0.1.0"
  @spec section_head(t(), code(), String.t()) :: t()
  def section_head(doc, code \\ nil, text) do
    title = Text.new(code, text, true)
    underscore = Text.new(String.duplicate("-", String.length(text)), true)
    %{doc | entries: [underscore, title | doc.entries]}
  end

  @doc "Add table to document"
  @doc since: "0.1.0"
  @spec table(t(), Table.t()) :: t()
  def table(doc, table) do
    %{doc | entries: [table | doc.entries]}
  end
end
