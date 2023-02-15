defmodule Clik.Output.Text do
  defstruct [:code, :data]

  def new(code \\ nil, text) do
    %__MODULE__{code: code, data: text}
  end
end

defimpl Clik.Renderable, for: Clik.Output.Text do
  alias IO.ANSI

  def render(t) do
    if t.code == nil do
      t.data
    else
      :erlang.iolist_to_binary(ANSI.format([t.code, t.data]))
    end
  end
end

defmodule Clik.Output.Break do
  defstruct [:amount]

  def new(amount \\ 1) do
    %__MODULE__{amount: amount}
  end
end

defimpl Clik.Renderable, for: Clik.Output.Break do
  import Clik.Output.Util, only: [os_break: 0]

  def render(b) do
    if b.amount > 1 do
      Enum.map(1..b.amount, fn _ -> os_break() end) |> Enum.join()
    else
      os_break()
    end
  end
end

defimpl Clik.Renderable, for: BitString do
  def render(s), do: s
end

defimpl Clik.Renderable, for: Integer do
  def render(i), do: Integer.to_string(i)
end

defimpl Clik.Renderable, for: Float do
  def render(f), do: Float.to_string(f)
end

defimpl Clik.Renderable, for: Atom do
  def render(a), do: Atom.to_string(a)
end
