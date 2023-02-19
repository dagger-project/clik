defmodule Clik do
  alias Clik.{Command, Output}

  @type commands :: %{atom() => Command.t()}

  @spec run(String.t(), [String.t()], commands(), IO.device(), IO.device()) :: :ok | :error
  def run(script_name, argv, commands, output \\ :stdout, err_output \\ :stderr) do
    case find_command(argv, commands) do
      {:ok, {args, command}} ->
        Command.run(command, script_name, args, output, err_output)

      {:error, :unknown_command} ->
        Output.puts(err_output, "Unknown command")
        :error

      {:error, :no_default} ->
        Output.puts(err_output, "Internal error")
        :error
    end
  end

  defp find_command([], commands) do
    if Map.has_key?(commands, :default) do
      {:ok, {[], Map.fetch!(commands, :default)}}
    else
      {:error, :no_default}
    end
  end

  defp find_command([arg | rest] = args, commands) do
    try do
      name = String.to_existing_atom(arg)

      if Map.has_key?(commands, name) do
        {:ok, {rest, Map.fetch!(commands, name)}}
      else
        if Map.has_key?(commands, :default) do
          {:ok, {args, Map.fetch!(commands, :default)}}
        else
          {:error, :unknown_command}
        end
      end
    rescue
      ArgumentError ->
        if Map.has_key?(commands, :default) do
          {:ok, {args, Map.fetch!(commands, :default)}}
        else
          {:error, :unknown_command}
        end
    end
  end
end
