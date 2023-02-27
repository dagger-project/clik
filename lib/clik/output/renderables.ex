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

defimpl String.Chars, for: Clik.Output.Text do
  alias Clik.Output.Text

  def to_string(text) do
    Text.format(text)
  end
end

defimpl Clik.Renderable, for: Clik.Output.Text do
  def render(text, out) do
    {IO.write(out, to_string(text)), out}
  end
end
