defmodule Clik do
  alias Clik.CommandEnvironment
  alias Clik.{Command, Registry}

  @type argv :: [] | [String.t()]
  @type result :: :ok | :error | {:error, atom()} | {:error, {atom(), term()}}

  @spec run(Registry.t(), argv()) :: result()
  def run(registry, args) do
    {:ok, global_opts} = Registry.prepare(registry)

    case OptionParser.parse_head(args, global_opts) do
      {_parsed, [], []} ->
        dispatch_to(registry, args, :default)

      {_parsed, [cmd_name | _], []} ->
        case resolve_command_name(registry, cmd_name) do
          {:ok, resolved} ->
            {final_args, final_cmd} =
              if resolved != :default do
                {args -- [cmd_name], resolved}
              else
                {args, resolved}
              end

            dispatch_to(registry, final_args, final_cmd)

          error ->
            error
        end

      {_, _, errors} ->
        option_names = for {option, _} <- errors, do: option
        {:error, {:unknown_options, option_names}}
    end
  end

  defp resolve_command_name(registry, name) do
    case convert_command_name(name) do
      nil ->
        if Registry.has_command?(registry, :default) do
          {:ok, :default}
        else
          {:error, {:unknown_command, name}}
        end

      converted ->
        cond do
          Registry.has_command?(registry, converted) ->
            {:ok, converted}

          Registry.has_command?(registry, :default) ->
            {:ok, :default}

          true ->
            {:error, {:unknown_command, name}}
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

  defp dispatch_to(registry, args, cmd_name) do
    case Registry.prepare(registry, cmd_name) do
      {:ok, options} ->
        case OptionParser.parse(args, options) do
          {parsed, remaining, []} ->
            case check_parsed_options(registry, cmd_name, parsed) do
              {:ok, updated_options} ->
                cmd = Registry.command!(registry, cmd_name)
                env = %CommandEnvironment{options: updated_options, arguments: remaining}
                run_command(cmd, env)

              {:error, :missing_option, name} ->
                {:error, {:missing_option, name}}
            end

          {_, _, errors} ->
            option_names = for {option, _} <- errors, do: option
            {:error, {:unknown_options, option_names}}
        end

      {:error, :unknown_command} ->
        if cmd_name == :default do
          {:error, :no_default}
        else
          {:error, {:unknown_command, cmd_name}}
        end
    end
  end

  defp check_parsed_options(registry, cmd_name, parsed) do
    {required, defaults} =
      Registry.options!(registry, cmd_name)
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
        {:halt, {:error, :missing_option, opt.long}}
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
end
