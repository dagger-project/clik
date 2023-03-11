defmodule Clik.Output.Text do
  @moduledoc """
  Formatted block of text.

  Represents either a partial or full line of text. Lines are terminated with the
  correct terminator based on platform.
  """
  alias IO.ANSI
  alias Clik.Platform
  defstruct [:eol?, :code, :text]

  @type t :: %__MODULE__{
          eol?: boolean(),
          code: atom(),
          text: String.t()
        }

  @spec new(atom(), bitstring(), boolean()) :: t()
  def new(code \\ nil, text, include_eol) do
    %__MODULE__{code: code, text: text, eol?: include_eol}
  end

  @spec append(t(), bitstring()) :: t()
  def append(t, new_text) do
    %{t | text: t.text <> new_text}
  end

  @spec format(t()) :: String.t()
  def format(text) do
    output =
      if text.code != nil do
        ANSI.format([text.code, text.text]) |> :erlang.iolist_to_binary()
      else
        text.text
      end

    if text.eol? do
      output <> Platform.eol_char()
    else
      output
    end
  end
end
