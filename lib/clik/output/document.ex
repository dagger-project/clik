defmodule Clik.Output.Document do
  defstruct [:entries]
  alias Clik.Renderable
  alias Clik.Output.{Break, Text}

  def empty(), do: %__MODULE__{entries: []}

  def clear(doc), do: %{doc | entries: []}

  def line(doc, code \\ nil, data) do
    doc
    |> text(code, data)
    |> break()
  end

  def break(doc, amount \\ 1) do
    %{doc | entries: [Break.new(amount) | doc.entries]}
  end

  def text(doc, code \\ nil, data)

  def text(doc, code, data) when is_binary(data) do
    %{doc | entries: [Text.new(code, data) | doc.entries]}
  end

  def text(doc, code, items) when is_list(items) do
    rendered = Enum.map(items, &Renderable.render(&1)) |> :erlang.iolist_to_binary()
    text(doc, code, rendered)
  end
end

defimpl Clik.Renderable, for: Clik.Output.Document do
  def render(d) do
    Enum.reverse(d.entries)
    |> Enum.map(&Clik.Renderable.render(&1))
    |> :erlang.iolist_to_binary()
  end
end
