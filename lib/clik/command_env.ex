defmodule Clik.CommandEnvironment do
  alias Clik.Option
  @enforce_keys [:script, :input, :output, :error]
  defstruct script: nil, options: nil, arguments: nil, input: nil, output: nil, error: nil

  @typedoc "Script name, parsed options, and arguments"
  @type t() :: %__MODULE__{
          script: String.t() | nil,
          options: [] | [Option.t()],
          arguments: [] | [String.t()]
        }

  @typedoc "Individual options used to configure a `Clik.CommandEnvironment`"
  @type opt() ::
          {:option, [] | [Option.t()]}
          | {:arguments, [] | [String.t()]}
          | {:input, IO.device()}
          | {:output, IO.device()}
          | {:error, IO.device()}

  @type opts :: [] | [opt()]

  @default_opts_args []
  @default_input_output :stdio
  @default_error :stderr

  @doc """
  Creates a new `Clik.CommandEnvironment` instance.

  Input, output, and error default to stdin, stdout, and stderr respectively.
  """
  @doc since: "0.1.0"
  @spec new(String.t(), opts()) :: t()
  def new(script_name, opts \\ []) do
    %__MODULE__{
      script: script_name,
      options: Keyword.get(opts, :options, @default_opts_args),
      arguments: Keyword.get(opts, :arguments, @default_opts_args),
      input: Keyword.get(opts, :input, @default_input_output),
      output: Keyword.get(opts, :output, @default_input_output),
      error: Keyword.get(opts, :error, @default_error)
    }
  end
end
