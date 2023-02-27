defprotocol Clik.Renderable do
  @moduledoc """
  Renders `term` and writes the resulting string to `out`.
  """
  @type target :: atom() | pid()
  @spec render(term(), target()) :: {:ok, target()} | {:error, atom()}
  def render(r, out)
end
