defmodule Clik.CommandEnvironment do
  alias Clik.Option
  @enforce_keys [:script]
  defstruct script: nil, options: [], arguments: []

  @typedoc "Script name, parsed options, and arguments"
  @type t() :: %__MODULE__{
          script: String.t() | nil,
          options: [] | [Option.t()],
          arguments: [] | [String.t()]
        }
end
