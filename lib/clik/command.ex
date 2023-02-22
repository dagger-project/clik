defmodule Clik.Command do
  alias Clik.{Argument, CommandEnvironment, Option}

  defstruct [:name, :cb_mod]

  @type t :: %__MODULE__{}
  @type options :: [] | [Option.t()]
  @type result :: :ok | {:error, atom()}

  @callback help_text() :: String.t()
  @callback options() :: options()
  @callback run(CommandEnvironment.t()) :: result()

  defmacro __using__(opts \\ []) do
    stubs = Keyword.get(opts, :stubs, true)

    quote do
      @behaviour unquote(__MODULE__)

      alias Clik.{Argument, CommandEnvironment, Option}

      if unquote(stubs) do
        def options(), do: []
        def help_text(), do: ""

        defoverridable(options: 0, help_text: 0)
      end
    end
  end

  @spec new(atom(), module()) :: {:ok, t()} | {:error, :badarg}
  def new(name, callback_module) when name == nil or callback_module == nil do
    {:error, :badarg}
  end

  def new(name, callback_module), do: {:ok, %__MODULE__{name: name, cb_mod: callback_module}}

  @spec new!(atom(), module()) :: t() | no_return()
  def new!(name, callback_module) do
    case new(name, callback_module) do
      {:ok, command} ->
        command

      {:error, :badarg} ->
        raise ArgumentError
    end
  end

  @spec options(t()) :: options()
  def options(cmd), do: cmd.cb_mod.options()

  @spec help_text(t()) :: String.t()
  def help_text(cmd), do: cmd.cb_mod.help_text()

  @spec run(t(), CommandEnvironment.t()) :: result()
  def run(cmd, env) do
    cmd.cb_mod.run(env)
  end
end
