defmodule Clik.Command do
  alias Clik.Command.Invocation
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
      alias Clik.Command.Invocation, as: CommandInvocation

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
        case cmd.cb_mod.handle(%Invocation{
               options: parsed,
               arguments: args,
               output: output,
               err_output: err_output
             }) do
          :help ->
            show_help(cmd, script_name, output)

          result ->
            result
        end

      {:error, {:missing_option, name}} ->
        d = Document.empty() |> Document.line("Required option --#{name} is missing")
        Output.puts(err_output, Renderable.render(d))
        :error
    end
  end

  defp show_help(cmd, script_name, device) do
    usage = "Usage: #{script_name} #{cmd.name}"
    options = cmd.cb_mod.options()

    doc =
      Document.empty()
      |> Document.line(usage)
      |> Document.break()
      |> Document.line(cmd.cb_mod.help_text())

    final_doc =
      if Enum.empty?(options) do
        doc
      else
        option_help =
          Enum.map(options, fn option ->
            {flags, type, help} = Option.help(option)

            {{String.length(flags), flags}, {String.length(type), type},
             {String.length(help), help}}
          end)

        flag_col = column_width(option_help, 1)
        type_col = column_width(option_help, 2)
        help_col = column_width(option_help, 3)

        Enum.reduce(options, doc, fn option, doc ->
          {flag, type, help} = Option.help(option)

          Document.column(doc, flag_col, flag)
          |> Document.column(type_col, type)
          |> Document.column(help_col, help)
          |> Document.break()
        end)
      end

    Output.puts(device, Renderable.render(final_doc))
  end

  defp column_width([], _), do: 1

  defp column_width(option_help, column) do
    {result, _} =
      Enum.max_by(option_help, fn {{a, _}, {b, _}, {c, _}} ->
        case column do
          1 ->
            a

          2 ->
            b

          3 ->
            c
        end
      end)

    result
  end
end
