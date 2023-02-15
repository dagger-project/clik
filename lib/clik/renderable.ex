defprotocol Clik.Renderable do
  @type error :: {:error, atom()}
  @spec render(term()) :: iolist() | binary()
  def render(t)
end
