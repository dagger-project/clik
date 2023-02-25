defprotocol Clik.Renderable do
  @type target :: atom() | pid()
  @spec render(term(), target()) :: {:ok, target()} | {:error, atom()}
  def render(r, out)
end
