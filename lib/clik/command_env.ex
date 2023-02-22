defmodule Clik.CommandEnvironment do
  defstruct [:script, :options, :arguments]

  @type t() :: %__MODULE__{}
end
