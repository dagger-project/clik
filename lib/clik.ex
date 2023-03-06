defmodule Clik do
  alias Clik.CommandEnvironment
  alias Clik.{Command, Configuration}
  alias Clik.Output.HelpFormatter

  @typedoc "Raw args from CLI"
  @type argv :: [] | [String.t()]

  @typedoc "Error during arg parsing or command dispatch"
  @type error ::
          {:missing_option, atom()}
          | {:unknown_command, atom()}
          | {:unknown_options, [String.t()]}
          | {:error, atom()}

  @typedoc "Execution result"
  @type result :: :ok | error()

  @doc """
  CLI execution entry point.

  Parses CLI args based on the configuration and calls the correct command.
  `run/2` should be called from the main function.

  ## Example
  ```
  defmodule MyCLIApp do
    alias Clik.Configuration

    def main(args) do
      config =
        Configuration.add_command!(%Configuration{}, Command.new!(:default, MyCLIApp.DefaultCommand))
      case Clik.run(config, args) do
        :ok ->
          :erlang.halt(0)
        {:error, reason} ->
          :erlang.halt(1)
    end
  end
  ```
  """
  @doc since: "0.1.0"
  @spec run(Configuration.t(), argv(), CommandEnvironment.t()) :: result()
  def run(config, args, env) do
    {:ok, global_opts} = Configuration.prepare(config)

    case OptionParser.parse(args, global_opts) do
      {parsed, [], []} ->
        if Keyword.get(parsed, :help, false) do
          show_script_help(config, env)
        else
          dispatch_to(config, env, args, :default)
        end

      {parsed, [cmd_name | _], _} ->
        case resolve_command_name(config, cmd_name) do
          {:ok, resolved} ->
            {final_args, final_cmd} =
              if resolved != :default do
                {args -- [cmd_name], resolved}
              else
                {args, resolved}
              end

            if Keyword.get(parsed, :help, false) do
              show_command_help(config, env, resolved)
            else
              dispatch_to(config, env, final_args, final_cmd)
            end

          error ->
            error
        end

      {_, _, errors} ->
        option_names = for {option, _} <- errors, do: option
        {:unknown_options, option_names}
    end
  end

  defp resolve_command_name(config, name) do
    case convert_command_name(name) do
      nil ->
        if Configuration.has_command?(config, :default) do
          {:ok, :default}
        else
          {:unknown_command, name}
        end

      converted ->
        cond do
          Configuration.has_command?(config, converted) ->
            {:ok, converted}

          Configuration.has_command?(config, :default) ->
            {:ok, :default}

          true ->
            {:unknown_command, name}
        end
    end
  end

  defp convert_command_name(name) when is_bitstring(name) do
    try do
      String.to_existing_atom(name)
    rescue
      ArgumentError ->
        nil
    end
  end

  defp dispatch_to(config, env, args, cmd_name) do
    case Configuration.prepare(config, cmd_name) do
      {:ok, options} ->
        case OptionParser.parse(args, options) do
          {parsed, remaining, []} ->
            case check_parsed_options(config, cmd_name, parsed) do
              {:ok, updated_options} ->
                cmd = Configuration.command!(config, cmd_name)
                run_command(cmd, %{env | options: updated_options, arguments: remaining})

              error ->
                error
            end

          {_, _, errors} ->
            option_names = for {option, _} <- errors, do: option
            {:unknown_options, option_names}
        end

      {:error, :unknown_command} ->
        if cmd_name == :default do
          :no_default
        else
          {:unknown_command, cmd_name}
        end
    end
  end

  defp check_parsed_options(config, cmd_name, parsed) do
    {required, defaults} =
      Configuration.options!(config, cmd_name)
      |> Map.values()
      |> Enum.filter(&(&1.required == true or &1.default != nil))
      |> Enum.split_with(&(&1.required == true))

    case check_required(required, parsed) do
      true ->
        add_defaults(defaults, parsed)

      error ->
        error
    end
  end

  defp check_required(required, parsed) do
    Enum.reduce_while(required, true, fn opt, _ ->
      if Keyword.has_key?(parsed, opt.long) do
        {:cont, true}
      else
        {:halt, {:missing_option, opt.long}}
      end
    end)
  end

  defp add_defaults(defaults, parsed) do
    updated =
      Enum.reduce(defaults, parsed, fn opt, acc ->
        if Keyword.has_key?(acc, opt.long) do
          acc
        else
          [{opt.long, opt.default} | acc]
        end
      end)

    {:ok, updated}
  end

  defp run_command(cmd, env) do
    Command.run(cmd, env)
  end

  defp show_script_help(config, env) do
    doc = HelpFormatter.script_help(config)
    Clik.Renderable.render(doc, env.output)
  end

  defp show_command_help(config, env, cmd_name) do
    doc = HelpFormatter.command_help!(config, cmd_name)
    Clik.Renderable.render(doc, env.output)
  end
end
