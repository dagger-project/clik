defmodule Clik.CommandInvocation do
  @type t :: %__MODULE__{}
  defstruct [:options, :arguments]
end

defmodule Clik.Command do
  alias Clik.CommandInvocation
  alias Clik.{Option, Options}
  alias Clik.Output.Document
  alias Clik.Renderable

  @type t :: %__MODULE__{}

  defstruct [:script_name, :name, :cb_mod]

  @callback options() :: Option.options()
  @callback help_text() :: String.t()
  @callback handle(CommandInvocation.t()) :: :ok | :error | :help

  @show_help [:error, :help]

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)
      alias Clik.Option
      alias Clik.Output.Document
      alias Clik.Renderable

      def options(), do: []

      defoverridable(options: 0)
    end
  end

  @spec new(atom(), atom()) :: t()
  def new(name, callback),
    do: %__MODULE__{name: name, cb_mod: callback}

  @spec run(t(), [String.t()]) :: :ok | no_return()
  def run(cmd, argv) do
    case Options.parse(argv, cmd.cb_mod.options()) do
      {:ok, {parsed, args}} ->
        if cmd.cb_mod.handle(%CommandInvocation{options: parsed, arguments: args}) in @show_help do
          show_help(cmd)
        end

      {:error, {:missing_option, name}} ->
        d = Document.empty() |> Document.line("Required option --#{name} is missing")
        IO.puts(:stderr, Renderable.render(d))
    end
  end

  defp show_help(cmd) do
    d =
      Document.empty()
      |> Document.text("Usage: ")
      |> Document.text(Atom.to_string(cmd.name))
      |> Document.break()
      |> Document.text(cmd.cb_mod.help_text())

    IO.puts(Renderable.render(d))
  end
end
