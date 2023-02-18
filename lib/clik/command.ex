defmodule Clik.CommandInvocation do
  @type t :: %__MODULE__{}
  defstruct [:options, :arguments]
end

defmodule Clik.Command do
  alias Clik.CommandInvocation
  alias Clik.{Option, Options, Output}
  alias Clik.Output.Document
  alias Clik.Renderable

  @type t :: %__MODULE__{}
  @type registry :: %{atom() => t()}

  defstruct [:script_name, :name, :cb_mod]

  @callback options() :: Option.options()
  @callback help_text() :: String.t()
  @callback handle(CommandInvocation.t()) :: :ok | :error | :help

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)
      alias Clik.Option
      alias Clik.Output.Document
      alias Clik.Renderable

      def options(), do: []

      @spec new(atom()) :: Click.Command.t()
      def new(name) do
        %Clik.Command{name: name, cb_mod: __MODULE__}
      end

      defoverridable(options: 0)
    end
  end

  @spec register(t(), registry()) :: {:ok, registry()} | :error
  def register(cmd, commands) do
    register(cmd, cmd.name, commands)
  end

  @spec register(t(), atom(), registry()) :: {:ok, registry()} | :error
  def register(cmd, name, commands) do
    if Map.has_key?(commands, name) do
      :error
    else
      {:ok, Map.put(commands, name, cmd)}
    end
  end

  @spec run(t(), String.t(), [String.t()], IO.device(), IO.device()) :: :ok | no_return()
  def run(cmd, script_name, argv, output, err_output) do
    case Options.parse(argv, cmd.cb_mod.options()) do
      {:ok, {parsed, args}} ->
        case cmd.cb_mod.handle(%CommandInvocation{options: parsed, arguments: args}) do
          :help ->
            show_help(cmd, script_name, output)

          result ->
            result
        end

      {:error, {:missing_option, name}} ->
        d = Document.empty() |> Document.line("Required option --#{name} is missing")
        Output.puts(err_output, Renderable.render(d))
    end
  end

  defp show_help(cmd, script_name, device) do
    d =
      Document.empty()
      |> Document.text("Usage: #{script_name}")
      |> Document.break()
      |> Document.text(cmd.cb_mod.help_text())

    Output.puts(device, Renderable.render(d))
  end
end
