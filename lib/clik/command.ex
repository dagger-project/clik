defmodule Clik.Command do
  alias Clik.{Argument, CommandEnvironment, Option}

  @enforce_keys [:name, :cb_mod, :default?]
  defstruct [:name, :cb_mod, :default?]

  @typedoc "An executable command"
  @type t :: %__MODULE__{
          name: atom(),
          cb_mod: module(),
          default?: boolean()
        }

  @typedoc "List of command options"
  @type option_map :: %{} | %{atom() => Option.t()}

  @type result :: :ok | {:error, atom()}

  @doc "Returns short help blurb"
  @callback help_text() :: String.t() | nil

  @doc "Returns list of command-specific options"
  @callback options() :: option_map()

  @doc "Executes the command"
  @callback run(CommandEnvironment.t()) :: result()

  defmacro __using__(opts \\ []) do
    stubs = Keyword.get(opts, :stubs, true)

    quote do
      @behaviour unquote(__MODULE__)

      alias Clik.{Argument, CommandEnvironment, Option}

      if unquote(stubs) do
        @impl true
        def options(), do: []

        @impl true
        def help_text(), do: ""

        defoverridable(options: 0, help_text: 0)
      end
    end
  end

  @doc """
  Creates a new `Clik.Command` instance.

  Returns `{:error, :badarg}` if:

  * `name` or `callback_module` are nil
  * Loading `callback_module` via `Code.ensure_loaded/1` fails
  """
  @doc since: "0.1.0"
  @spec new(atom(), module(), boolean()) :: {:ok, t()} | {:error, :badarg}
  def new(name, callback_module, default \\ false)

  def new(name, callback_module, _default) when name == nil or callback_module == nil do
    {:error, :badarg}
  end

  def new(name, callback_module, default) do
    case Code.ensure_loaded(callback_module) do
      {:module, ^callback_module} ->
        {:ok, %__MODULE__{name: name, cb_mod: callback_module, default?: default}}

      {:error, _} ->
        {:error, :badarg}
    end
  end

  @doc """
  Creates a new `Clik.Command` instance.

  Raises `ArgumentError` if:

  * `name` or `callback_module` are nil
  * Loading `callback_module` via `Code.ensure_loaded/1` fails
  """
  @doc since: "0.1.0"
  @spec new!(atom(), module(), boolean()) :: t() | no_return()
  def new!(name, callback_module, default \\ false) do
    case new(name, callback_module, default) do
      {:ok, command} ->
        command

      {:error, :badarg} ->
        raise ArgumentError
    end
  end

  @doc """
  Fetch list of command-specific options.
  """
  @doc since: "0.1.0"
  @spec options(t()) :: option_map()
  def options(cmd), do: cmd.cb_mod.options()

  @doc """
  Fetch command implementation's help blurb.
  """
  @doc since: "0.1.0"
  @spec help_text(t()) :: String.t()
  def help_text(cmd), do: cmd.cb_mod.help_text()

  @doc """
  Executes a command.
  """
  @doc since: "0.1.0"
  @spec run(t(), CommandEnvironment.t()) :: result()
  def run(cmd, env) do
    cmd.cb_mod.run(env)
  end
end
